Program Tenris;
uses
  SysUtils, Windows, Messages, Graphics, ShellAPI,
 DGLEngine_header in 'DGLEngine_header.pas';
  {$R Tenris.res}
{---------------------------------------------}
type
 Tpole=object {игровое поле}
  width, height:byte; {параметры}
  map:array[1..16, 1..26] of byte; {карта чисел}
  metki, nap:array[1..16, 1..26] of boolean;
  procedure show; {показать поле}
  procedure Init;
  procedure Test;
  //procedure Test; {тест на сгорание}
 end;

 TTetr=array[1..3, 1..3] of byte;

 Tfig=object {падающая фигня}
  sx, sy, predX, predY:integer; {координаты блока}
  tetr:TTetr; mooving:boolean;
  procedure Load;
  procedure Left;
  procedure Right;
  procedure Down(megadown:boolean);
  procedure Show; {нарисовать}
  procedure Rot;
  function Fishka:boolean; {стыковка с стаканом}
  procedure Copy; {копирования обьекта}
 end;

 var
  pole:Tpole;
  figura:Tfig;
  rec, ss:word;
  f:text;

  fon, font1, font2, font3, logo, kbdTimer, gameTimer:cardinal;
  logo_transp, dx:byte; time:word;
  fullscrean, testis, firstrec:boolean;
  param:string;
  rot_sound, leftright_sound, down_sound, clear_sound, fulpad, key_sound:integer;

{------------Методы---------------}
Function Tfig.Fishka:boolean;
var t:boolean; x, y:byte;
begin
   t:=false;
   For x:=1 to 3 do
    for y:=1 to 3 do
     If ((tetr[x,y]>0) and (pole.map[x+sx, y+sy]>0))
      then t:=true;
   Fishka:=t;
end;

Procedure TFig.Load;
var f:text; j, c, r, x, y, buf, s:byte; pus:string;
begin
   assign(f, 'figures.dat');
   reset(f);
   Readln(f, c); {количество фигур}
   Randomize;
   r:=Random(c)+1;
   For j:=1 to c do
    begin
       Readln(f);
       If r=j
        then begin
          For y:=1 to 3 do
           begin
              For x:=1 to 3 do
               begin
                  Read(f, buf);
                  tetr[x, y]:=buf;
                  If buf=1 then {загадать число}
                   begin
                      s:=Random(9)+1;
                      tetr[x, y]:=s;
                   end;
               end;
              Readln(f);
           end;
        end
        else begin
         Readln(f);
         Readln(f);
         Readln(f);
        end;
    end;
   Close(f);
   sx:=7;
   sy:=-2;
end;

Procedure Tfig.Show;
var x, y:byte;
begin
   For y:=1 to 3 do
    For x:=1 to 3 do
     If tetr[x, y]>0 then
      begin
          If y+sy>=1 then begin
                //прямоугольник
                DrawRectangle2D_Fill_VertexColor(((x+sx)*25-25)+1+dx, ((y+sy)*25-25), 24, 24, $00FF00, $00FF00, $41BE3A, $579548, 237, 237, 237, 237);
                DrawRectangle2D( ((x+sx)*25-25)+dx, ((y+sy)*25-25), 25, 25, $000000, 200, false);
                //число
                DrawText2D(font1, ((x+sx)*25-25)+6+dx, ((y+sy)*25-25)-2, IntToStr(tetr[x, y]), $FFFF80, 220);
          end;
      end;
end;

procedure Tfig.left;
var soundX:real;
begin
   predX:=sx;
   predY:=sy;
   If sx>=1 then sx:=sx-1;
   If Fishka or mooving then
    begin
      sx:=predX;
      sy:=predY;
    end
   else
    begin
        soundX:=((sx-8)+0.5)/6;
        SetSample3DPosition(leftright_sound, soundX-1, sy/26, 3);
        SetSampleVolume(leftright_sound, 85);
        PlaySample(leftright_sound);
    end;
   //mooving:=true;
end;

procedure Tfig.Right;
var soundX:real;
begin
   predX:=sx;
   predY:=sy;
   If sx<13 then sx:=sx+1;
   If Fishka or mooving then
    begin
      sx:=predX;
      sy:=predY;
    end
    else
    begin
        soundX:=((sx-8)+0.5)/6;
        SetSample3DPosition(leftright_sound, soundX+1, sy/26, 3);
        SetSampleVolume(leftright_sound, 85);
        PlaySample(leftright_sound);
    end;
   //mooving:=true;
end;

procedure Tfig.Down(megadown:boolean);

 function Lim:boolean;
 var t:boolean; x, y:byte;
 begin
   t:=false;
   For x:=1 to 3 do
    for y:=1 to 3 do
     If ((tetr[x,y]>0) and ((sy+y)>24))
      then t:=true;
   Lim:=t;
 end;

begin
   If megadown then
    begin
     repeat
        predX:=sx;
        predY:=sy;
        sy:=sy+1;
        Show;
     until ((Fishka) or Lim);
    end
   else
    begin
     predX:=sx;
     predY:=sy;
     sy:=sy+1;
    end;

   If ((Fishka) or Lim) then {перенос фигурки на поле}
    begin
      sx:=predX;
      sy:=predY;
      Copy;
      Load;
    end;

end;

procedure Tfig.Rot;
var c1, c2:byte; soundX:real;
begin
  c1:=tetr[1, 2];
  tetr[1,2]:=tetr[2,1];
  c2:=tetr[2, 3];
  tetr[2,3]:=c1;
  c1:=tetr[3,2];
  tetr[3,2]:=c2;
  tetr[2,1]:=c1;

  c1:=tetr[1,3];
  tetr[1,3]:=tetr[1,1];
  c2:=tetr[3,3];
  tetr[3,3]:=c1;
  c1:=tetr[3,1];
  tetr[3,1]:=c2;
  tetr[1,1]:=c1;

  //звук
  soundX:=((sx-8)+0.5)/5;
  SetSample3DPosition(rot_sound, soundX, sy/52, 1);
  SetSampleVolume(rot_sound, 90);
  PlaySample(rot_sound);


end;

Procedure Tfig.Copy;
var x, y:byte; soundX:real;
begin
   {копирование обьекта}
   For y:=1 to 3 do
    For x:=1 to 3 do
     begin
         If tetr[x, y]>0 then pole.map[x+sx, y+sy]:=tetr[x, y];
     end;
   //звук
  soundX:=((sx-8)+0.5)/4;
  SetSample3DPosition(down_sound, soundX, 0.5-sy/52, 0.5);
  SetSampleVolume(down_sound, 100);
  PlaySample(down_sound);

  //можно запускать тест
  testis:=true;
end;

Procedure Tpole.Init;
var j, i:byte;
begin
   For j:=1 to 26 do
    For i:=1 to 16 do
     begin
        map[i, j]:=0;
        metki[i, j]:=false;
     end;
end;

Procedure Tpole.Show;
var x, y:byte;
begin
   For y:=1 to 26 do
    For x:=1 to 16 do
     If map[x, y]>0 then
      begin
          If not metki[x, y] then
           begin
                //красный квадрат
                DrawRectangle2D_Fill_VertexColor((x*25-25)+1+dx, (y*25-25), 24, 24, $AA00FF, $AA60FF, $0080FF, $0000FF, 225, 225, 225, 225);
                DrawRectangle2D( (x*25-25)+dx, (y*25-25), 25, 25, $000000, 200, false);
                //число
                DrawText2D(font1, (x*25-25)+6+dx, (y*25-25)-2, IntToStr(map[x, y]), $FFFFFF, 240);
           end
           else begin
                //желтый квадрат
                DrawRectangle2D_Fill_VertexColor((x*25-25)+1+dx, (y*25-25), 24, 24, $80FFFF, $A0FFFF, $00FFFF, $00FFFF, 238, 238, 238, 238);
                DrawRectangle2D( (x*25-25)+dx, (y*25-25), 25, 25, $000000, 200, false);
                //число
                DrawText2D(font1, (x*25-25)+6+dx, (y*25-25)-2, IntToStr(map[x, y]), $0000ff, 250);
                testis:=true;
           end;

          {form1.pic.Canvas.Pen.Color:=clBlack;
          form1.pic.Canvas.Pen.Style:=psSolid;
          If metki[x, y]
           then form1.pic.Canvas.Brush.Color:=clYellow
           else form1.pic.Canvas.Brush.Color:=clRed;
          form1.pic.Canvas.Rectangle( x*25-25, y*25-25, x*25, y*25);
          form1.pic.Canvas.Font.Size:=12;
          form1.pic.Canvas.Font.Name:='Comic Sans MS';
          //form1.pic.Canvas.Font.Style:=fsBold;
          If metki[x, y]
           then form1.pic.Canvas.Font.Color:=clRed
           else form1.pic.Canvas.Font.Color:=clWhite;
          form1.pic.Canvas.TextOut((x*25-22), (y*25-24), IntToStr(map[x, y])); }
      end;
end;

procedure Tpole.Test;
var x, y:byte; res:integer; soundx:real;

function gameover:boolean;
var i:byte; t:boolean;
begin
   t:=false;
   For i:=1 to 16 do
    If map[i, 1]>0 then t:=true;
   gameover:=t;
end;

Procedure Padenie(x0, y0:byte);
 var
  x, y, ymin:byte; j:word; soundx:real;
begin
   //очистить матрицу
   For x:=1 to 16 do
    For y:=1 to 26 do
     begin
        nap[x, y]:=false;
     end;

   //выделение
   nap[x0, y0]:=true;
   For j:=1 to 1000 do
    For y:=1 to 26 do
     For x:=1 to 16 do
      begin
        If ((nap[x, y]) and (map[x+1, y]>0))
         then nap[x+1, y]:=true;
        If ((nap[x, y]) and (pole.map[x-1, y]>0) )
         then nap[x-1, y]:=true;
        If ((nap[x, y]) and (pole.map[x, y-1]>0))
         then nap[x, y-1]:=true;
        If ((nap[x, y]) and (pole.map[x, y+1]>0) and (y<26))
         then nap[x, y+1]:=true;
      end;

    //нахождение минимального игрика
    ymin:=y0;
    For y:=1 to 26 do
     For x:=1 to 16 do
      If ((nap[x,y]) and (y>ymin)) then ymin:=y;
    //ShowMessage(IntTostr(ymin));

   //опускание
   If ymin<24 then begin
     //ищезновение
     For y:=26 downto 2 do
      For x:=1 to 16 do
        If nap[x,y-1] then
         begin
            map[x, y]:=map[x, y-1];
            map[x, y-1]:=0;

            //звук
           soundX:=((x-8)-1)/6;
           SetSample3DPosition(fulpad, soundX, 0, 1.5);
           SetSampleVolume(fulpad, 95);
           PlaySample(fulpad);
         end;
     //появление
   end;
   //Show;
end;

begin
   //очистка
   For x:=1 to 16 do
    For y:=1 to 26 do
     begin
        If pole.metki[x, y] then pole.map[x, y]:=0;
        pole.metki[x, y]:=false;
     end;

   For y:=1 to 25 do
     For x:=1 to 16 do
      If ((map[x, y]>0)) then Padenie(x, y);

   For x:=1 to 15 do
    For y:=1 to 25 do
     begin
        //горизонталь
       If ((pole.map[x, y]<>0) and (pole.map[x+1, y]<>0) and (pole.map[x, y]+pole.map[x+1, y]=10)) then
        begin
           pole.metki[x, y]:=true;
           pole.metki[x+1, y]:=true;
           ss:=ss+10;

           //звук
           soundX:=((x-8)-1)/6;
           SetSample3DPosition(clear_sound, soundX, 0.5-y/52, 1);
           SetSampleVolume(clear_sound, 95);
           PlaySample(clear_sound);
        end;
       //вертикаль
       If ((pole.map[x, y]<>0) and (pole.map[x, y+1]<>0) and (pole.map[x, y]+pole.map[x, y+1]=10)) then
        begin
           pole.metki[x, y]:=true;
           pole.metki[x, y+1]:=true;
           ss:=ss+10;

           //звук
           soundX:=((x-8)-1)/6;
           SetSample3DPosition(clear_sound, soundX, 0.5-y/52, 1);
           SetSampleVolume(clear_sound, 95);
           PlaySample(clear_sound);
        end;
     end;
    //If (ss>100) and (ss<150) then fon:=LoadTextureFromFile('girl2.jpg');
    //If (ss>300) and (ss<350) then fon:=LoadTextureFromFile('girl3.jpg');
    If (ss>rec) and (firstrec) then
     begin
        DisableTimer(gametimer); DisableTimer(kbdtimer);
        MessageBox(0,'Рекорд побит!','information',$2040);
        EnableTimer(gametimer); EnableTimer(kbdtimer);
        firstrec:=false;
     end;

    If GameOver then
     begin
        DisableTimer(gameTimer); DisableTimer(kbdTimer);
        MessageBox(0, 'Game over!', 'TeNRiS', $1010);
        MessageBox(0, PChar('Total score: '+IntToStr(ss)), 'Game over', $1020);
        res:=MessageBox(0, 'Play again?', 'TeNRiS', $2023);
        case res of
         6: begin
                   pole.Init;
                   figura.Load;
                   ss:=0;
                   EnableTimer(gameTimer); EnableTimer(kbdTimer);
                end;
         IdNo: QuitEngine;
        end;
     end;
end;

{----------------}

procedure Free;
var f:integer;
begin
  //сохранение рекорда
  If ss>rec then begin
  f:=FileCreate('record.dat');
  If (f<>-1) and (ss>rec) then
   begin
      FileWrite(f, ss, SizeOf(ss));//сохраняем текущее количество очков.
      FileClose(f);
   end;
  end;
  MessageBox(0, 'Спасибо что играете в игры от NiCketT-software', 'TeNRiS', $1040);
end;

procedure Init;
var bmp1, bmp2:TBitmap; f:integer;
begin
  SendMessage(DGLEngineDLL_Handle, WM_SETICON, 1, LoadIcon(hInstance, 'MAINICON'));
  If not fullscrean then ShowCursor(True);
   //загрузка текстур
  fon:=LoadTextureFromFile(GetCurrentDir+'\texture\picture.jpg');
  font1:=LoadFontFromFile(GetCurrentDir+'\texture\font1.dft');
  font2:=LoadFontFromFile(GetCurrentDir+'\texture\font2.dft');
  font3:=LoadFontFromFile(GetCurrentDir+'\texture\font3.dft');
  bmp1:=TBitmap.Create;
  bmp1.LoadFromFile(GetCurrentDir+'\texture\logo.bmp');
  bmp2:=TBitmap.Create;
  bmp2.Handle:=LoadBitmap(hInstance,PChar('MASK'));
  logo:=LoadTexture(bmp1, TEXDETAIL_BEST, TRANSCOLOR_NONE, 1, bmp2);
  bmp1.Free;
  bmp2.Free;
  EnableTimer(gameTimer); EnableTimer(kbdTimer);
  logo_transp:=0; time:=1;
  //загрузка звуков
  DirectSoundInit;
  rot_sound:=LoadSample(GetCurrentDir+'\sounds\buh.wav');
  leftright_sound:=LoadSample(GetCurrentDir+'\sounds\move.wav');
  clear_sound:=LoadSample(GetCurrentDir+'\sounds\clear.wav');
  down_sound:=LoadSample(GetCurrentDir+'\sounds\down.wav');
  key_sound:=LoadSample(GetCurrentDir+'\sounds\rotate.wav');
  fulpad:=LoadSample(GetCurrentDir+'\sounds\hit.wav');
  PlayMusic(GetCurrentDir+'\sounds\crasy frog.mid',TRUE);

  //загрузка рекорда
  f:=FileOpen('record.dat', fmOpenRead);
  If (f<>-1)
   then FileRead(f, rec, SizeOf(rec))
   else rec:=200; //по умолчанию
  FileClose(f);
  firstrec:=true;

  figura.Load;
  pole.Init; testis:=false;
  ss:=0;
  ApplicationName('TeNRiS II');
end;

procedure Draw;
begin
  //нарисовать фон
  dx:=0;
  If fullscrean then dx:=Round((GetScreenResX-400)/2);
  Begin2D;
    DrawTexture2D_Simple(fon, dx+1 , 1, 400, 600); //фон
    DrawTexture2D(logo, dx+400-151 , 600-83, 150, 80, 0, logo_transp, $FFFFFF, false, false, false); //логотип

    //фигурки
    figura.Show;
    pole.show;

    DrawText2D(font2, dx+285, 20, 'Score: '+IntToStr(ss), $FF00FF, 255);
    DrawText2D(font3, dx+5, 5, 'top score: '+IntToStr(rec), $00FF00, 255); //очки
    //ApplicationName(PChar('TeNRiS, ver-2.1  (score: '+IntToStr(ss)+')'));
  End2D;
end;

procedure Process;
begin
   //показываем логотип
   If time>=1 then
    begin
       time:=time+1;
       If (time>=5) and (time<=55) then logo_transp:=5*(time-5); //загорание
       If (time>130) and (time<=180) then logo_transp:=250-5*(time-130);
       If time>=3000 then time:=0;
    end;
   //ApplicationName(PChar('TeNRiS             (score: '+IntToStr(ss)+')'));
end;

procedure gameProcess;
begin
   figura.mooving:=false;
   figura.Down(false);
   If testis then pole.Test;
   testis:=false;
end;

procedure KeyboardProcess;
var soundx:real;
begin
     //обработка клавиш
   If IsKeyPressed(key_up) then figura.Rot;
   If IsKeyPressed(Key_Left) then figura.Left;
   If IsKeyPressed(Key_Right) then figura.Right;
   If IsKeyPressed(Key_Space) then figura.Down(true);
   If IsKeyPressed(Key_Down) then begin
       //звук
       soundX:=((figura.sx-8)+0.5)/5;
       SetSample3DPosition(key_sound, soundX, figura.sy/26, 2);
       SetSampleVolume(key_sound, 95);
       PlaySample(key_sound);

       figura.Down(false);
       figura.Down(false);
       figura.Down(false);
   end;
   If IsKeyPressed(Key_Escape) then QuitEngine;
   If IsKeyPressed(Key_F1) then
   ShellExecute(0, PChar('open'), PChar('readme.txt'), Nil, PChar(GetCurrentDir), SW_ShowNormal);
   If IsKeyPressed(Key_R) then begin
       pole.Init;
       figura.Load;
       ss:=0;
   end;
   If IsKeyPressed(Key_S) then begin
       If IsMusicPlaying
        then StopMusic
        else PlayMusic(GetCurrentDir+'\sounds\crasy frog.mid',TRUE); 
   end;

end;


begin

 if LoadDGLEngineDLL('DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@Init);
  RegProcedure(PROC_FREE,@Free);

  //SetWindowPosition(150, 120);
  //загрузка параметров
  fullscrean:=false;
  If (ParamCount>=1) and (ParamStr(1)='fullscrean') then
   begin
      //установка стандартных значений
      fullscrean:=true;
      //установка значений из ini-файла
      SetEngineInitParametrs(800, 600, 32, 85, true, false, true, true);
   end
   else SetEngineInitParametrs(400, 600, 32, 0, false, false, false, true);

  SetGameProcessInterval(100);
  ApplicationName('TeNRiS. Loadding...');
  kbdTimer:=AddTimer(25, @KeyboardProcess);
  gameTimer:=AddTimer(750, @gameProcess);
  PleaseNoLogo;
  EnableTimer(gameTimer);
  EnableTimer(kbdTimer);

  StartEngine;
  FreeDGLEngineDLL('Tenris.exe');
 end;

end.
