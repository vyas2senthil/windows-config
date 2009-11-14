#include <windows.h>
#include <immdev.h>
#include "imedefs.h"
#include <regstr.h>
#include "imewnd.h"

static int comp_wnd_width()
{
	CRect rect;
	GetWindowRect(g_hCompWnd, &rect);
	return rect.Width();
}

static int comp_wnd_height()
{
	CRect rect;
	GetWindowRect(g_hCompWnd, &rect);
	return rect.Height();	
}

BOOL PASCAL FitInLazyOperation(LPPOINT lpptOrg, LPPOINT lpptNearCaret, 
							   LPRECT lprcInputRect, u32 uEsc)
{
	return false;
	POINT ptDelta, ptTol;
	RECT rcUIRect, rcInterRect;

	ptDelta.x = lpptOrg->x - lpptNearCaret->x;

	ptDelta.x = (ptDelta.x >= 0) ? ptDelta.x : -ptDelta.x;

	ptTol.x = sImeG.iParaTol * ncUIEsc[uEsc].iParaFacX +
		sImeG.iPerpTol * ncUIEsc[uEsc].iPerpFacX;

	ptTol.x = (ptTol.x >= 0) ? ptTol.x : -ptTol.x;

	if (ptDelta.x > ptTol.x) {
		return FALSE;
	}

	ptDelta.y = lpptOrg->y - lpptNearCaret->y;

	ptDelta.y = (ptDelta.y >= 0) ? ptDelta.y : -ptDelta.y;

	ptTol.y = sImeG.iParaTol * ncUIEsc[uEsc].iParaFacY +
		sImeG.iPerpTol * ncUIEsc[uEsc].iPerpFacY;

	ptTol.y = (ptTol.y >= 0) ? ptTol.y : -ptTol.y;

	if (ptDelta.y > ptTol.y) {
		return FALSE;
	}
	// build up the UI rectangle (composition window)
	rcUIRect.left = lpptOrg->x;
	rcUIRect.top = lpptOrg->y;
	rcUIRect.right = rcUIRect.left + comp_wnd_width();
	rcUIRect.bottom = rcUIRect.top + comp_wnd_height();

	if (IntersectRect(&rcInterRect, &rcUIRect, lprcInputRect)) {
		return FALSE;
	}

	return (TRUE);
}

void PASCAL GetNearCaretPosition(LPPOINT lpptFont,
								 u32 uEsc,
								 u32 uRot,
								 LPPOINT lpptCaret,
								 LPPOINT lpptNearCaret, 
								 BOOL fFlags)
{
	LONG lFontSize;
	LONG xWidthUI, yHeightUI, xBorder, yBorder;
	RECT rcWorkArea;

	if ((uEsc + uRot) & 0x0001) {
		lFontSize = lpptFont->x;
	} else {
		lFontSize = lpptFont->y;
	}

	xWidthUI = comp_wnd_width();
	yHeightUI = comp_wnd_height();
	xBorder = 0;
	yBorder = 0;

	if (fFlags & NEAR_CARET_FIRST_TIME) {
		lpptNearCaret->x = lpptCaret->x +
			lFontSize * ncUIEsc[uEsc].iLogFontFacX +
			sImeG.iPara * ncUIEsc[uEsc].iParaFacX +
			sImeG.iPerp * ncUIEsc[uEsc].iPerpFacX;

		if (ptInputEsc[uEsc].x >= 0) {
			lpptNearCaret->x += xBorder * 2;
		} else {
			lpptNearCaret->x -= xWidthUI - xBorder * 2;
		}

		lpptNearCaret->y = lpptCaret->y +
			lFontSize * ncUIEsc[uEsc].iLogFontFacY +
			sImeG.iPara * ncUIEsc[uEsc].iParaFacY +
			sImeG.iPerp * ncUIEsc[uEsc].iPerpFacY;

		if (ptInputEsc[uEsc].y >= 0) {
			lpptNearCaret->y += yBorder * 2;
		} else {
			lpptNearCaret->y -= yHeightUI - yBorder * 2;
		}
	} else {
		lpptNearCaret->x = lpptCaret->x +
			lFontSize * ncAltUIEsc[uEsc].iLogFontFacX +
			sImeG.iPara * ncAltUIEsc[uEsc].iParaFacX +
			sImeG.iPerp * ncAltUIEsc[uEsc].iPerpFacX;

		if (ptAltInputEsc[uEsc].x >= 0) {
			lpptNearCaret->x += xBorder * 2;
		} else {
			lpptNearCaret->x -= xWidthUI - xBorder * 2;
		}

		lpptNearCaret->y = lpptCaret->y +
			lFontSize * ncAltUIEsc[uEsc].iLogFontFacY +
			sImeG.iPara * ncAltUIEsc[uEsc].iParaFacY +
			sImeG.iPerp * ncAltUIEsc[uEsc].iPerpFacY;

		if (ptAltInputEsc[uEsc].y >= 0) {
			lpptNearCaret->y += yBorder * 2;
		} else {
			lpptNearCaret->y -= yHeightUI - yBorder * 2;
		}
	}

	rcWorkArea = get_wa_rect();

	if (lpptNearCaret->x < rcWorkArea.left) {
		lpptNearCaret->x = rcWorkArea.left;
	} else if (lpptNearCaret->x + xWidthUI > rcWorkArea.right) {
		lpptNearCaret->x = rcWorkArea.right - xWidthUI;
	}

	if (lpptNearCaret->y < rcWorkArea.top) {
		lpptNearCaret->y = rcWorkArea.top;
	} else if (lpptNearCaret->y + yHeightUI > rcWorkArea.bottom) {
		lpptNearCaret->y = rcWorkArea.bottom - yHeightUI;
	}

	return;
}

BOOL PASCAL AdjustCompPosition(
	input_context& ic, 
	LPPOINT lpptOrg, 
	LPPOINT lpptNew)
{
	POINT ptNearCaret, ptOldNearCaret;
	u32 uEsc, uRot;
	RECT rcUIRect, rcInputRect, rcInterRect;
	POINT ptFont;

	// we need to adjust according to font attribute
	if (ic->lfFont.A.lfWidth > 0) {
		ptFont.x = ic->lfFont.A.lfWidth * 2;
	} else if (ic->lfFont.A.lfWidth < 0) {
		ptFont.x = -ic->lfFont.A.lfWidth * 2;
	} else if (ic->lfFont.A.lfHeight > 0) {
		ptFont.x = ic->lfFont.A.lfHeight;
	} else if (ic->lfFont.A.lfHeight < 0) {
		ptFont.x = -ic->lfFont.A.lfHeight;
	} else {
		ptFont.x = comp_wnd_height();
	}

	if (ic->lfFont.A.lfHeight > 0) {
		ptFont.y = ic->lfFont.A.lfHeight;
	} else if (ic->lfFont.A.lfHeight < 0) {
		ptFont.y = -ic->lfFont.A.lfHeight;
	} else {
		ptFont.y = ptFont.x;
	}

	// if the input char is too big, we don't need to consider so much
	if (ptFont.x > comp_wnd_height() * 8) {
		ptFont.x = comp_wnd_height() * 8;
	}
	if (ptFont.y > comp_wnd_height() * 8) {
		ptFont.y = comp_wnd_height() * 8;
	}

	if (ptFont.x < sImeG.xChiCharWi) {
		ptFont.x = sImeG.xChiCharWi;
	}

	if (ptFont.y < sImeG.yChiCharHi) {
		ptFont.y = sImeG.yChiCharHi;
	}
	// -450 to 450 index 0
	// 450 to 1350 index 1
	// 1350 to 2250 index 2
	// 2250 to 3150 index 3
	uEsc = (u32) ((ic->lfFont.A.lfEscapement + 450) / 900 % 4);
	uRot = (u32) ((ic->lfFont.A.lfOrientation + 450) / 900 % 4);

	// decide the input rectangle
	rcInputRect.left = lpptNew->x;
	rcInputRect.top = lpptNew->y;

	// build up an input rectangle from escapemment
	rcInputRect.right = rcInputRect.left + ptFont.x * ptInputEsc[uEsc].x;
	rcInputRect.bottom = rcInputRect.top + ptFont.y * ptInputEsc[uEsc].y;

	// be a normal rectangle, not a negative rectangle
	if (rcInputRect.left > rcInputRect.right) {
		LONG tmp;

		tmp = rcInputRect.left;
		rcInputRect.left = rcInputRect.right;
		rcInputRect.right = tmp;
	}

	if (rcInputRect.top > rcInputRect.bottom) {
		LONG tmp;

		tmp = rcInputRect.top;
		rcInputRect.top = rcInputRect.bottom;
		rcInputRect.bottom = tmp;
	}

	GetNearCaretPosition(&ptFont, uEsc, uRot, lpptNew, &ptNearCaret,
						 NEAR_CARET_FIRST_TIME);

	// 1st, use the adjust point
	// build up the new suggest UI rectangle (composition window)
	rcUIRect.left = ptNearCaret.x;
	rcUIRect.top = ptNearCaret.y;
	rcUIRect.right = rcUIRect.left + comp_wnd_width();
	rcUIRect.bottom = rcUIRect.top + comp_wnd_height();

	ptOldNearCaret = ptNearCaret;

	// OK, no intersect between the near caret position and input char
	if (IntersectRect(&rcInterRect, &rcUIRect, &rcInputRect)) {
	} else
		if (FitInLazyOperation(lpptOrg, &ptNearCaret, &rcInputRect, uEsc))
	{
		// happy ending!!!, don't change position
		return FALSE;
	} else {
		*lpptOrg = ptNearCaret;

		// happy ending!!
		return (TRUE);
	}

	// unhappy case
	GetNearCaretPosition(&ptFont, uEsc, uRot, lpptNew, &ptNearCaret, 0);

	// build up the new suggest UI rectangle (composition window)
	rcUIRect.left = ptNearCaret.x;
	rcUIRect.top = ptNearCaret.y;
	rcUIRect.right = rcUIRect.left + comp_wnd_width();
	rcUIRect.bottom = rcUIRect.top + comp_wnd_height();

	// OK, no intersect between the adjust position and input char
	if (IntersectRect(&rcInterRect, &rcUIRect, &rcInputRect)) {
	} else
		if (FitInLazyOperation(lpptOrg, &ptNearCaret, &rcInputRect, uEsc))
	{
		return FALSE;
	} else {
		*lpptOrg = ptNearCaret;

		return (TRUE);
	}

	*lpptOrg = ptOldNearCaret;

	return (TRUE);
}

void PASCAL SetCompPosition(input_context& ic)
{
	POINT ptWnd;
	BOOL fChange = FALSE;

	ptWnd.x = 0;
	ptWnd.y = 0;

	ClientToScreen(g_hCompWnd, &ptWnd);

	POINT ptNew;			// new position of UI

	ptNew.x = ic->cfCompForm.ptCurrentPos.x;
	ptNew.y = ic->cfCompForm.ptCurrentPos.y;
	ClientToScreen((HWND) ic->hWnd, &ptNew);
	fChange = AdjustCompPosition(ic, &ptWnd, &ptNew);


	if (!fChange) {
		return;
	}
	SetWindowPos(g_hCompWnd, NULL,
				 ptWnd.x, ptWnd.y,
				 0, 0, SWP_NOACTIVATE | SWP_NOSIZE | SWP_NOZORDER);

	return;
}

void PASCAL MoveDefaultCompPosition(HWND hUIWnd)
{
	if (!g_hCompWnd) {
		return;
	}

	input_context ic(hUIWnd);
	if (!ic) {
		return;
	}

	SetCompPosition(ic);
	return;
}

void show_comp_wnd()
{
	ShowWindow(g_hCompWnd, SW_SHOWNOACTIVATE);
}

void hide_comp_wnd()
{
	ShowWindow(g_hCompWnd, SW_HIDE);
}

void PASCAL StartComp(HWND hUIWnd)
{
	input_context ic(hUIWnd);
	if (!ic) {
		return;
	}

	if (!g_hCompWnd) {
		g_hCompWnd = CreateWindowEx(0, szCompClassName, NULL, WS_POPUP | WS_DISABLED,
									0, 0, comp_dft_width, comp_dft_height, hUIWnd,
									(HMENU) NULL, g_hInst, NULL);
	}

	SetCompPosition(ic);
	show_comp_wnd();

	return;
}

static void high_light(HDC hdc, const CRect& rect)
{
	HDC hdc_mem = CreateCompatibleDC(hdc); 

	HBITMAP hbitmap = CreateCompatibleBitmap(hdc, 
											 rect.right-rect.left,
											 rect.bottom-rect.top);
	HBITMAP hbitmap_old = SelectObject(hdc_mem, hbitmap); 
	HBRUSH hbrush = CreateSolidBrush(0x2837df);
    
	RECT rect_mem = {0, 0, rect.Width(), rect.Height()};
	FillRect(hdc_mem, &rect_mem, hbrush);

	BitBlt(hdc, 
		   rect.left, rect.top,
		   rect.Width(), rect.Height(),
		   hdc_mem,
		   0,0, 
		   SRCINVERT);

	DeleteObject(hbrush);
	SelectObject(hdc_mem, hbitmap_old);
	DeleteObject(hbitmap);
	DeleteObject(hdc_mem);
}

void draw_cands(HDC hdc, const CRect& rect, const vector<string>& cands)
{
	hdc_with_font dc_lucida(hdc, L"Lucida Console");

	int left = rect.left;
	CRect rc_text = rect;
	wstring seq = L"0:";

	BHJDEBUG(" first %d, active %d, last %d", g_first_cand, g_active_cand, g_last_cand);
	if (g_first_cand > g_last_cand && g_first_cand != g_active_cand) {
		for (int i=g_last_cand; i>=0; i--) {
			if (seq[0] == L'9') {
				seq[0] = L'0';
			} else {
				seq[0] += 1;
			}
			
			u32 seq_width = dc_lucida.get_text_width(seq);
			wstring cand = to_wstring(cands[i]);
			u32 cand_width = dc_lucida.get_text_width(cand);

			left += seq_width + cand_width + 6;
			if (left > rect.right && i != g_last_cand) {
				g_first_cand = i+1;
				break;
			} else {
				g_first_cand = i;
			}
		}
	} else {
		g_last_cand = g_first_cand;
	}

	left = rect.left;
	if (g_first_cand <= g_last_cand) {
		for (size_t i=g_first_cand; i<cands.size() && i-g_first_cand < (u32)10; i++) {
			if (seq[0] == L'9') {
				seq[0] = L'0';
			} else {
				seq[0] += 1;
			}

			u32 seq_width = dc_lucida.get_text_width(seq);
			wstring cand = to_wstring(cands[i]);
			u32 cand_width = dc_lucida.get_text_width(cand);
			if (left + seq_width + cand_width + 6 > (u32)rect.right
				&& i != g_first_cand) {
				g_last_cand = i-1;
				break;
			} else {
				g_last_cand = i;
			}
				
			rc_text.left = left;
			left += seq_width;
			rc_text.right = left;
			left += 2;
			SetTextColor(hdc, RGB(0, 0, 0));
			dc_lucida.draw_text(seq, rc_text);


			rc_text.left = left;
			left += cand_width;
			rc_text.right = left;
			left += 4;
			dc_lucida.draw_text(cand, rc_text);

			if (i == g_active_cand) {
				high_light(hdc, rc_text);
			} 
		}
	}
	BHJDEBUG(" first %d, active %d, last %d", g_first_cand, g_active_cand, g_last_cand);
}

void PASCAL PaintCompWindow(HDC hdc)
{
	CRect rcWnd;
	GetClientRect(g_hCompWnd, &rcWnd);
	Rectangle(hdc, rcWnd.left, rcWnd.top, rcWnd.right, rcWnd.bottom);

	rcWnd.left += 5;
	rcWnd.right -= 5;

	CRect rc_top = rcWnd;
	rc_top.bottom = (rcWnd.top+rcWnd.bottom)/2;

	CRect rc_bot = rcWnd;
	rc_bot.top = rc_top.bottom;



	if (g_comp_str.size()) {
		wstring wstr = to_wstring(g_comp_str);
		DrawText(hdc, wstr.c_str(), wstr.size(), &rc_top, DT_VCENTER|DT_SINGLELINE);
	} 

	if (g_quail_rules.find(g_comp_str) != g_quail_rules.end()) {
		draw_cands(hdc, rc_bot, g_quail_rules[g_comp_str]);
	}

	MoveToEx(hdc, rcWnd.left, (rcWnd.top+rcWnd.bottom)/2, NULL);
	LineTo(hdc, rcWnd.right, (rcWnd.top+rcWnd.bottom)/2);
	return;
}

LRESULT CALLBACK CompWndProc(HWND hWnd, u32 uMsg, WPARAM wParam, LPARAM lParam)
{

	//BHJDEBUG("received msg %s", msg_name(uMsg));

	if (!g_hCompWnd) {
		g_hCompWnd = hWnd;
	} else if (g_hCompWnd != hWnd) {
		BHJDEBUG(" Error: CompWndProc hWnd %x is not g_hCompWnd %x", hWnd, g_hCompWnd);	
		exit(-1);
	}
	
	switch (uMsg) {
	case WM_IME_NOTIFY:
		BHJDEBUG(" wm_ime_notify wp %x, lp %x", wParam, lParam);
		// must not delete this case, because DefWindowProc will hang the IME
		break;
	case WM_PAINT:
		{
			HDC hDC;
			PAINTSTRUCT ps;

			hDC = BeginPaint(g_hCompWnd, &ps);
			PaintCompWindow(hDC);
			EndPaint(g_hCompWnd, &ps);
		}
		break;
	case WM_MOUSEACTIVATE:
		return (MA_NOACTIVATE);
	default:
		//BHJDEBUG(" msg %s not handled", msg_name(uMsg));
		return DefWindowProc(g_hCompWnd, uMsg, wParam, lParam);
	}
	return (0L);
}
