#ifndef __IME_WND_H__
#define __IME_WND_H__
#include <windows.h>
#include <atltypes.h>
#include <immdev.h>
#include <string>
using std::string;
using std::wstring;

typedef UINT u32;
class CBhjWnd {
public:
	CBhjWnd() {m_hWnd = 0;};
	virtual void paint() = 0;
	virtual void init(HWND hwnd) {
		m_hWnd = hwnd;
	};
private:
	HWND m_hWnd;
};

class CBhjStatusWnd : public CBhjWnd 
{
public:
	virtual void paint() {};
};

class CBhjCompCandWnd : public CBhjWnd
{
public:
	virtual void paint() {};
};

void debug_rect(const CRect& rect);
void FillSolidRect(HDC hdc, const CRect& rect, COLORREF rgb);

class input_context
{
public:	
	input_context(HIMC himc, LPTRANSMSG msg_buf = NULL, u32 msg_buf_size = 0);
	~input_context() {
		if (m_himc) {
			ImmUnlockIMC(m_himc);
		}
	}

	LPINPUTCONTEXT operator->() {
		return m_ic;
	}
	
	operator bool() {
		if (m_ic) {
			return true;
		} else {
			return false;
		}
	}

	bool add_msg(u32 msg, WPARAM wp, LPARAM lp);
private:
	bool enlarge_msg_buf(u32 n);
	bool copy_old_msg();

private:
	LPINPUTCONTEXT m_ic;
	HIMC m_himc;
	LPTRANSMSG m_msg_buf;
	u32 m_msg_buf_size;
	u32 m_num_msg;
};
extern string g_comp_str;

// int MultiByteToWideChar(
//   UINT CodePage, 
//   DWORD dwFlags,         
//   LPCSTR lpMultiByteStr, 
//   int cbMultiByte,       
//   LPWSTR lpWideCharStr,  
//   int cchWideChar        
// );

wstring to_wstring(const string& str);

#endif
