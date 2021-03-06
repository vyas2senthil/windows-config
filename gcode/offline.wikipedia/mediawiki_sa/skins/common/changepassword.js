
window.onNameChange = function() {
	if ( wgUserName != document.getElementById('wpName').value ) {
		document.getElementById('wpPassword').disabled = true;
		document.getElementById('wpComment').disabled = false;
	} else {
		document.getElementById('wpPassword').disabled = false;
		document.getElementById('wpComment').disabled = true;
	}
}

window.onNameChangeHook = function() {
	document.getElementById( 'wpName' ).onblur = onNameChange;
}

addOnloadHook( onNameChangeHook );
