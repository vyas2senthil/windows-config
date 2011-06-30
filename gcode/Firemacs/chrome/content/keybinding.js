////////////////////////////////////////////////////////////////
//
// Automatically generated by Haskell with YML
//

Firemacs.Commands = {};

Firemacs.Commands.View = {
    ScrollLineUp: function(e) {
        goDoCommand('cmd_scrollLineUp');
    },
    ScrollLineDown: function(e) {
        goDoCommand('cmd_scrollLineDown');
    },
    PreviousTab: function(e) {
        this._sfun.moveTab(-1);
    },
    NextTab: function(e) {
        this._sfun.moveTab(1);
    },
    ViScrollLineUp: function(e) {
        goDoCommand('cmd_scrollLineUp');
    },
    ViScrollLineDown: function(e) {
        goDoCommand('cmd_scrollLineDown');
    },
    ViScrollLeft: function(e) {
        goDoCommand('cmd_scrollLeft');
    },
    ViScrollRight: function(e) {
        goDoCommand('cmd_scrollRight');
    },
    ViPreviousTab: function(e) {
        this._sfun.moveTab(-1);
    },
    ViNextTab: function(e) {
        this._sfun.moveTab(1);
    },
    ViScrollPageUp: function(e) {
        goDoCommand('cmd_scrollPageUp');
    },
    ViScrollPageDown: function(e) {
        goDoCommand('cmd_scrollPageDown');
    },
    PreviousPage: function(e) {
        if (typeof(BrowserBack) == 'function') { BrowserBack(); }
    },
    NextPage: function(e) {
        if (typeof(BrowserForward) == 'function') { BrowserForward(); }
    },
    ReloadPage: function(e) {
        if (typeof(BrowserReload) == 'function') { BrowserReload(); }
    },
    ViScrollTop: function(e) {
        goDoCommand('cmd_scrollTop');
    },
    ViScrollBottom: function(e) {
        goDoCommand('cmd_scrollBottom');
    },
    ScrollTop: function(e) {
        goDoCommand('cmd_scrollTop');
    },
    ScrollBottom: function(e) {
        goDoCommand('cmd_scrollBottom');
    }
};

Firemacs.Commands.Edit = {
    PreviousLine: function(e) {
        if (this._sfun.bob(e) && this._preference.getWalkForm()) { this._sfun.moveFocus(e, -1); } else { this._sfun.PreviousLine(e); }
    },
    NextLine: function(e) {
        if (this._sfun.eob(e) && this._preference.getWalkForm()) { this._sfun.moveFocus(e, 1); } else { this._sfun.NextLine(e); }
    },
    PreviousChar: function(e) {
        this._sfun.PreviousChar(e);
    },
    NextChar: function(e) {
        this._sfun.NextChar(e);
    },
    ArrowPreviousLine: function(e) {
        if (this._sfun.bob(e) && this._preference.getWalkForm()) { this._sfun.moveFocus(e, -1); } else { this._sfun.PreviousLine(e); }
    },
    ArrowNextLine: function(e) {
        if (this._sfun.eob(e) && this._preference.getWalkForm()) { this._sfun.moveFocus(e, 1); } else { this._sfun.NextLine(e); }
    },
    ArrowPreviousChar: function(e) {
        this._sfun.PreviousChar(e);
    },
    ArrowNextChar: function(e) {
        this._sfun.NextChar(e);
    },
    BeggingOfLine: function(e) {
        if (this._sfun.marked(e)) { goDoCommand('cmd_selectBeginLine'); } else { goDoCommand('cmd_beginLine'); }
    },
    EndOfLine: function(e) {
        if (this._sfun.marked(e)) { goDoCommand('cmd_selectEndLine'); } else { goDoCommand('cmd_endLine'); }
    },
    SetMarkAlias: function(e) {
        this._sfun.setMark(e);
    },
    SetMark: function(e) {
        this._sfun.setMark(e);
    },
    KillRegion: function(e) {
        goDoCommand('cmd_cut'); this._sfun.resetMark(e);
    },
    KillLineForward: function(e) {
        this._sfun.resetMark(e); goDoCommand('cmd_selectEndLine'); goDoCommand('cmd_copy'); goDoCommand('cmd_deleteToEndOfLine'); this._sfun.resetMark(e);
    },
    KillLineBackward: function(e) {
        this._sfun.resetMark(e); goDoCommand('cmd_selectBeginLine'); goDoCommand('cmd_copy'); goDoCommand('cmd_deleteToBeginningOfLine'); this._sfun.resetMark(e);
    },
    Paste: function(e) {
        goDoCommand('cmd_paste');
    },
    DeleteCharForward: function(e) {
        goDoCommand('cmd_deleteCharForward');
    },
    DeleteCharBackward: function(e) {
        goDoCommand('cmd_deleteCharBackward');
    },
    Undo: function(e) {
        goDoCommand('cmd_undo');
    },
    NextWord: function(e) {
        if (this._sfun.marked(e)) { goDoCommand('cmd_selectWordNext'); } else { goDoCommand('cmd_wordNext'); }
    },
    PreviousWord: function(e) {
        if (this._sfun.marked(e)) { goDoCommand('cmd_selectWordPrevious'); } else { goDoCommand('cmd_wordPrevious'); }
    },
    DeleteWordForward: function(e) {
        goDoCommand('cmd_deleteWordForward');
    },
    DeleteWordBackward: function(e) {
        goDoCommand('cmd_deleteWordBackward');
    },
    MoveTop: function(e) {
        if (this._sfun.marked(e)) { goDoCommand('cmd_selectTop'); } else { goDoCommand('cmd_moveTop'); }
    },
    MoveBottom: function(e) {
        if (this._sfun.marked(e)) { goDoCommand('cmd_selectBottom'); } else { goDoCommand('cmd_moveBottom'); }
    }
};

Firemacs.Commands.Common = {
    AllTabs: function(e) {
        this._sfun.allTabs();
    },
    SearchForward: function(e) {
        this._sfun.SearchOpen(); var findField = this._sfun.SearchField(); if (findField && findField.value && findField.value !== '') { this._sfun.SearchForward(); }
    },
    SearchBackword: function(e) {
        this._sfun.SearchOpen(); var findField = this._sfun.SearchField(); if (findField && findField.value && findField.value !== '') { this._sfun.SearchBackward(); }
    },
    ScrollPageUp: function(e) {
        goDoCommand('cmd_scrollPageUp');
    },
    ScrollPageDown: function(e) {
        goDoCommand('cmd_scrollPageDown');
    },
    ResetMark: function(e) {
        this._sfun.SearchUnhilite(); this._sfun.SearchClose(); this._sfun.resetMark(e);
    },
    JumpURLBar: function(e) {
        var urlbar = document.getElementById('urlbar'); if (urlbar) { urlbar.select(); urlbar.focus(); }
    },
    JumpSearchBar: function(e) {
        var searchbar = document.getElementById('searchbar'); if (searchbar) { searchbar.select(); searchbar.focus(); }
    },
    FocusBody: function(e) {
        this._sfun.focusBody();
    },
    JumpInput: function(e) {
        this._sfun.moveFocus(e, 0);
    },
    JumpSubmit: function(e) {
        this._sfun.moveButton(e, 0);
    },
    CmPreviousTab: function(e) {
        this._sfun.moveTab(-1);
    },
    CmNextTab: function(e) {
        this._sfun.moveTab(1);
    },
    CloseTab: function(e) {
        if (typeof(BrowserCloseTabOrWindow) == 'function') { BrowserCloseTabOrWindow(); }
    },
    OpenFile: function(e) {
        if (typeof(BrowserOpenFileWindow) == 'function') { BrowserOpenFileWindow(); }
    },
    Copy: function(e) {
        goDoCommand('cmd_copy'); this._sfun.resetMark(e);
    },
    NextButton: function(e) {
        this._sfun.moveButton(e, 1);
    },
    PreviousButton: function(e) {
        this._sfun.moveButton(e, -1);
    },
    KillAccessKeys: function(e) {
        this._sfun.killAccesskeys(e);
    },
    NewLine: function(e) {
        if (e.originalTarget.parentNode.parentNode == this._sfun.SearchField()) { this._sfun.SearchUnhilite(); this._sfun.SearchClose(); } else { this._sfun.generateKey(e, KeyEvent.DOM_VK_RETURN);}
    },
    CopyUrl: function(e) {
        this._sfun.copyText(getBrowser().contentDocument.location.href); this._sfun._displayMessage('URL copied', 2000);
    },
    CopyTitle: function(e) {
        this._sfun.copyText(getBrowser().contentDocument.title); this._sfun._displayMessage('Title copied', 2000);
    },
    CopyTitleAndUrl: function(e) {
        this._sfun.copyText(getBrowser().contentDocument.title+'\n'+getBrowser().contentDocument.URL); this._sfun._displayMessage('Title and URL copied', 2000);
    },
    WebSearch: function(e) {
        this._sfun.webSearch(e);
    },
    MapSearch: function(e) {
        this._sfun.mapSearch(e);
    },
    SavePage: function(e) {
        this._sfun.pageSave(e);
    },
    SelectAll: function(e) {
        goDoCommand('cmd_selectAll')
    }
};

Firemacs.Commands.Menu = {
    PreviousCompletion: function(e) {
        this._sfun.PreviousCompletion(e);
    },
    NextCompletion: function(e) {
        this._sfun.NextCompletion(e);
    }
};

Firemacs.CmdKey = {};

Firemacs.CmdKey.Option = {
    UseEscape: true,
    UseAlt: true,
    UseMeta: false,
    XPrefix: 'C-x',
    AccessRegex: 'wiki',
    TurnoffRegex: '',
    WalkForm: true,
    EditOnly: false
};

Firemacs.CmdKey.View = {
    ScrollLineUp: 'C-p',
    ScrollLineDown: 'C-n',
    PreviousTab: 'C-b',
    NextTab: 'C-f',
    ViScrollLineUp: 'k',
    ViScrollLineDown: 'j',
    ViScrollLeft: 'H',
    ViScrollRight: 'L',
    ViPreviousTab: 'h',
    ViNextTab: 'l',
    ViScrollPageUp: 'b',
    ViScrollPageDown: 'u',
    PreviousPage: 'B',
    NextPage: 'F',
    ReloadPage: 'R',
    ViScrollTop: '<',
    ViScrollBottom: '>',
    ScrollTop: 'M-<',
    ScrollBottom: 'M->'
};

Firemacs.CmdKey.Edit = {
    PreviousLine: 'C-p',
    NextLine: 'C-n',
    PreviousChar: 'C-b',
    NextChar: 'C-f',
    ArrowPreviousLine: 'up',
    ArrowNextLine: 'down',
    ArrowPreviousChar: 'left',
    ArrowNextChar: 'right',
    BeggingOfLine: 'C-a',
    EndOfLine: 'C-e',
    SetMarkAlias: 'C-SPC',
    SetMark: 'C-i',
    KillRegion: 'C-w',
    KillLineForward: 'C-k',
    KillLineBackward: 'C-u',
    Paste: 'C-y',
    DeleteCharForward: 'C-d',
    DeleteCharBackward: 'C-h',
    Undo: 'C-xu',
    NextWord: 'M-f',
    PreviousWord: 'M-b',
    DeleteWordForward: 'M-d',
    DeleteWordBackward: 'M-DEL',
    MoveTop: 'M-<',
    MoveBottom: 'M->'
};

Firemacs.CmdKey.Common = {
    AllTabs: 'C-xb',
    SearchForward: 'C-s',
    SearchBackword: 'C-r',
    ScrollPageUp: 'M-v',
    ScrollPageDown: 'C-v',
    ResetMark: 'C-g',
    JumpURLBar: 'C-xl',
    JumpSearchBar: 'C-xg',
    FocusBody: 'C-x.',
    JumpInput: 'C-xt',
    JumpSubmit: 'C-xs',
    CmPreviousTab: 'C-M-b',
    CmNextTab: 'C-M-f',
    CloseTab: 'C-xk',
    OpenFile: 'C-xC-f',
    Copy: 'M-w',
    NextButton: 'M-n',
    PreviousButton: 'M-p',
    KillAccessKeys: 'M-k',
    NewLine: 'C-m',
    CopyUrl: 'C-M-u',
    CopyTitle: 'C-M-t',
    CopyTitleAndUrl: 'C-M-b',
    WebSearch: 'C-xC-e',
    MapSearch: 'C-xC-a',
    SavePage: 'C-xC-s',
    SelectAll: 'C-xh'
};

Firemacs.CmdKey.Menu = {
    PreviousCompletion: 'C-p',
    NextCompletion: 'C-n'
};

