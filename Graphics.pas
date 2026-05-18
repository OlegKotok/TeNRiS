unit Graphics;
interface
uses Windows;
type
  TBitmap = class
  public
    Handle: HBITMAP;
    procedure LoadFromFile(const FileName: string);
    constructor Create;
    destructor Destroy; override;
  end;
implementation
constructor TBitmap.Create; begin Handle := 0; end;
procedure TBitmap.LoadFromFile(const FileName: string);
begin Handle := LoadImage(0, PChar(FileName), IMAGE_BITMAP, 0, 0, LR_LOADFROMFILE); end;
destructor TBitmap.Destroy; begin if Handle <> 0 then DeleteObject(Handle); inherited; end;
end.
