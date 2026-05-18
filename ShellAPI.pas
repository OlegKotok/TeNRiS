unit ShellAPI;
interface
uses Windows;
const SW_ShowNormal = 1;
function ShellExecute(hWnd: HWND; Operation, FileName, Parameters, Directory: PChar; ShowCmd: Integer): HINST; stdcall; external 'shell32.dll' name 'ShellExecuteA';
implementation
end.
