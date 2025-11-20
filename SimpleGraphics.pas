unit SimpleGraphics;
interface
uses Windows, Classes, SysUtils;

type
  // Simple TBitmap replacement
  TBitmap = class
  private
    FHandle: HBITMAP;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadFromFile(const FileName: string);
    property Handle: HBITMAP read FHandle write FHandle;
  end;

// Tlhelp32 replacement - direct Windows API
type
  TProcessEntry32 = record
    dwSize: DWORD;
    cntUsage: DWORD;
    th32ProcessID: DWORD;
    th32DefaultHeapID: ULONG_PTR;
    th32ModuleID: DWORD;
    cntThreads: DWORD;
    th32ParentProcessID: DWORD;
    pcPriClassBase: LONG;
    dwFlags: DWORD;
    szExeFile: array[0..259] of CHAR;
  end;

const
  TH32CS_SNAPPROCESS = $00000002;

function CreateToolhelp32Snapshot(dwFlags, th32ProcessID: DWORD): THandle; stdcall; external 'kernel32.dll';
function Process32First(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall; external 'kernel32.dll';
function Process32Next(hSnapshot: THandle; var lppe: TProcessEntry32): BOOL; stdcall; external 'kernel32.dll';

implementation

constructor TBitmap.Create;
begin
  inherited Create;
  FHandle := 0;
end;

destructor TBitmap.Destroy;
begin
  if FHandle <> 0 then
    DeleteObject(FHandle);
  inherited Destroy;
end;

procedure TBitmap.LoadFromFile(const FileName: string);
begin
  if FHandle <> 0 then
    DeleteObject(FHandle);
  FHandle := LoadImage(0, PChar(FileName), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE);
end;

end.
