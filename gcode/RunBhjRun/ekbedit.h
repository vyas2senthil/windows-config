#if !defined(AFX_EKBEDIT_H__07E08AF6_1197_41EE_B6F1_30723513D39F__INCLUDED_)
#define AFX_EKBEDIT_H__07E08AF6_1197_41EE_B6F1_30723513D39F__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// EkbEdit.h : header file
//


#include "simplewnd.h"
/////////////////////////////////////////////////////////////////////////////
// CEkbEdit window
typedef enum {
	eNone = 0,
	eCtrl=1,
	eAlt=2,
	eShift=4,
	eCtrlAlt = eCtrl|eAlt,
	eCtrlAltShift= eCtrl|eAlt|eShift,
	eAltShift = eAlt|eShift,
	eCtrlShift = eCtrl|eShift,
} specKeyState_t;

class CEkbHistWnd;
#include <string>
#include <list>
using std::string;
using std::list;
class CEkbEdit : public CEdit
{
// Construction
public:
	CEkbEdit();

// Attributes
public:

// Operations
public:
	void weVeMoved();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CEkbEdit)
	public:
	virtual BOOL PreTranslateMessage(MSG* pMsg);
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CEkbEdit();

	int setHistFile(const CString& strFileName);
	void createListBox();
	void setListBox(CListBox& listBox);


	
private:
	specKeyState_t getSpecKeyState();
	void selectNextItem();
	void selectPrevItem(int prev=1);
	void getTextFromSelectedItem();

	void endOfLine();
	void beginOfLine();
	void killEndOfLine();
	void killBeginOfLine();
	void forwardChar();
	void backwardChar();
	void deleteChar();
	int GetLength();
	void backwardWord();
	void forwardWord();
	void backwardKillWord();
	void forwardKillWord();
	void escapeEdit();
	CString getText();
	void fillListBox(const CString& text);
	CListBox* m_listBox;
	CEkbHistWnd* m_simpleWnd;
	UINT m_id;
	CString m_strHistFile;
	void saveHist();
	string getSelected();
	void SetWindowText(const string& str);
	void SetWindowText(const CString& str);
	// Generated message map functions
protected:
	//{{AFX_MSG(CEkbEdit)
	afx_msg BOOL OnChange();
	afx_msg void OnKillFocus(CWnd* pNewWnd);
	afx_msg void OnSetFocus(CWnd* pOldWnd);
	//}}AFX_MSG

	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// CEkbHistWnd window

class CEkbHistWnd : public CWnd
{
// Construction
public:
	CEkbHistWnd(CEdit* master);
	CListBox* m_listBox;
private:
	CEdit* m_master;


// Attributes
public:

// Operations
public:
	void hide();
	void show();
	void weVeMoved();
private:
	void calcWindowRect(CRect& rect);

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CEkbHistWnd)
	//}}AFX_VIRTUAL

// Implementation
public:
	virtual ~CEkbHistWnd();

	// Generated message map functions
protected:
	//{{AFX_MSG(CEkbHistWnd)
	afx_msg void OnShowWindow(BOOL bShow, UINT nStatus);
	afx_msg void OnPaint();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_EKBEDIT_H__07E08AF6_1197_41EE_B6F1_30723513D39F__INCLUDED_)
