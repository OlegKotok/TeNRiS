program TeNRiS;

{$mode objfpc}{$H+}
{$IFDEF WINDOWS}{$APPTYPE GUI}{$ENDIF}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  SysUtils, 
  {$IFDEF WINDOWS}
  Windows, Messages, 
  {$ENDIF}
  Classes, Graphics, 
  DGLEngine_header;

{$R *.res}

{---------------------------------------------}
type
 TPole=object {игровое поле}
  width, height:byte; {размерность}
  map:array[1..16, 1..26] of byte; {карта поля}
  metki, nap:array[1..16, 1..26] of boolean;
  procedure show; {показать поле}
  procedure Init;
  procedure Test;
 end;

 TTetr=array[1..3, 1..3] of byte;

 TFig=object {падающая фигура}
  sx, sy, predX, predY:integer; {координаты фигуры}
  tetr:TTetr; 
  mooving:boolean;
  procedure Load;
  procedure Left;
  procedure Right;
  procedure Down(megadown:boolean);
  procedure Show; {отображение}
  procedure Rot;
  function Fishka:boolean; {проверка на пересечение}
  procedure Copy; {копирование в массив}
 end;

var
  pole:TPole;
  figura:TFig;
  rec, ss:word;
  f:text;

  fon, font1, font2, font3, logo, kbdTimer, gameTimer:cardinal;
  logo_transp, dx:byte; 
  time:word;
  fullscrean, testis, firstrec:boolean;
  param:string;
  rot_sound, leftright_sound, down_sound, clear_sound, fulpad, key_sound:integer;

{------------Фигура---------------}
function TFig.Fishka:boolean;
var t:boolean; x, y:byte;
begin
   t:=false;
   for x:=1 to 3 do
    for y:=1 to 3 do
     if ((tetr[x,y]>0) and (pole.map[x+sx, y+sy]>0)) then 
      t:=true;
   Fishka:=t;
end;

procedure TFig.Load;
var f:text; j, c, r, x, y, buf, s:byte;
begin
   assign(f, 'figures.dat');
   reset(f);
   readln(f, c); {количество фигур}
   randomize;
   r:=Random(c)+1;
   for j:=1 to c do
    begin
       readln(f);
       if r=j then 
        begin
          for y:=1 to 3 do
           begin
              for x:=1 to 3 do
               begin
                  read(f, buf);
                  tetr[x, y]:=buf;
                  if buf=1 then {случайный номер}
                   begin
                      s:=Random(9)+1;
                      tetr[x, y]:=s;
                   end;
               end;
              readln(f);
           end;
        end
        else begin
         readln(f);
         readln(f);
         readln(f);
        end;
    end;
   close(f);
   sx:=7;
   sy:=-2;
end;

procedure TFig.Show;
var x, y:byte;
begin
   for y:=1 to 3 do
    for x:=1 to 3 do
     if tetr[x, y]>0 then
      begin
          if y+sy>=1 then begin
                //прямоугольник
                DrawRectangle2D_Fill_VertexColor(((x+sx)*25-25)+1+dx, ((y+sy)*25-25), 24, 24, $00FF00, $00FF00, $41BE3A, $579548, 237, 237, 237, 237);
                DrawRectangle2D( ((x+sx)*25-25)+dx, ((y+sy)*25-25), 25, 25, $000000, 200, false);
                //цифра
                DrawText2D(font1, ((x+sx)*25-25)+6+dx, ((y+sy)*25-25)-2, IntToStr(tetr[x, y]), $FFFF80, 220);
          end;
      end;
end;

procedure TFig.left;
var soundX:real;
begin
   predX:=sx;
   predY:=sy;
   if sx>=1 then sx:=sx-1;
   if Fishka or mooving then
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
end;

procedure TFig.Right;
var soundX:real;
begin
   predX:=sx;
   predY:=sy;
   if sx<13 then sx:=sx+1;
   if Fishka or mooving then
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
end;

procedure TFig.Down(megadown:boolean);

 function Lim:boolean;
 var t:boolean; x, y:byte;
 begin
   t:=false;
   for x:=1 to 3 do
    for y:=1 to 3 do
     if ((tetr[x,y]>0) and ((sy+y)>24)) then 
      t:=true;
   Lim:=t;
 end;

begin
   if megadown then
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

   if ((Fishka) or Lim) then {фигурка упёрлась во что-то}
    begin
      sx:=predX;
      sy:=predY;
      Copy;
      Load;
    end;
end;

procedure TFig.Rot;
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

procedure TFig.Copy;
var x, y:byte; soundX:real;
begin
   {копирование в массив}
   for y:=1 to 3 do
    for x:=1 to 3 do
     begin
         if tetr[x, y]>0 then pole.map[x+sx, y+sy]:=tetr[x, y];
     end;
   //звук
  soundX:=((sx-8)+0.5)/4;
  SetSample3DPosition(down_sound, soundX, 0.5-sy/52, 0.5);
  SetSampleVolume(down_sound, 100);
  PlaySample(down_sound);

  //нужно проверить поле
  testis:=true;
end;

procedure TPole.Init;
var j, i:byte;
begin
   for j:=1 to 26 do
    for i:=1 to 16 do
     begin
        map[i, j]:=0;
        metki[i, j]:=false;
     end;
end;

procedure TPole.Show;
var x, y:byte;
begin
   for y:=1 to 26 do
    for x:=1 to 16 do
     if map[x, y]>0 then
      begin
          if not metki[x, y] then
           begin
                //обычный квадрат
                DrawRectangle2D_Fill_VertexColor((x*25-25)+1+dx, (y*25-25), 24, 24, $AA00FF, $AA60FF, $0080FF, $0000FF, 225, 225, 225, 225);
                DrawRectangle2D( (x*25-25)+dx, (y*25-25), 25, 25, $000000, 200, false);
                //цифра
                DrawText2D(font1, (x*25-25)+6+dx, (y*25-25)-2, IntToStr(map[x, y]), $FFFFFF, 240);
           end
           else begin
                //жёлтый квадрат
                DrawRectangle2D_Fill_VertexColor((x*25-25)+1+dx, (y*25-25), 24, 24, $80FFFF, $A0FFFF, $00FFFF, $00FFFF, 238, 238, 238, 238);
                DrawRectangle2D( (x*25-25)+dx, (y*25-25), 25, 25, $000000, 200, false);
                //цифра
                DrawText2D(font1, (x*25-25)+6+dx, (y*25-25)-2, IntToStr(map[x, y]), $0000ff, 250);
                testis:=true;
           end;
      end;
end;

procedure TPole.Test;
var x, y:byte; res:integer; soundx:real;

function gameover:boolean;
var i:byte; t:boolean;
begin
   t:=false;
   for i:=1 to 16 do
    if map[i, 1]>0 then t:=true;
   gameover:=t;
end;

procedure Padenie(x0, y0:byte);
var
  x, y, ymin:byte; j:word; soundx:real;
begin
   //очистить массив
   for x:=1 to 16 do
    for y:=1 to 26 do
     begin
        nap[x, y]:=false;
     end;

   //заполнение
   nap[x0, y0]:=true;
   for j:=1 to 1000 do
    for y:=1 to 26 do
     for x:=1 to 16 do
      begin
        if ((nap[x, y]) and (map[x+1, y]>0)) then
         nap[x+1, y]:=true;
        if ((nap[x, y]) and (pole.map[x-1, y]>0) ) then
         nap[x-1, y]:=true;
        if ((nap[x, y]) and (pole.map[x, y-1]>0)) then
         nap[x, y-1]:=true;
        if ((nap[x, y]) and (pole.map[x, y+1]>0) and (y<26)) then
         nap[x, y+1]:=true;
      end;

    //определить максимальную высоту
    ymin:=y0;
    for y:=1 to 26 do
     for x:=1 to 16 do
      if ((nap[x,y]) and (y>ymin)) then ymin:=y;

   //опускание
   if ymin<24 then begin
     //перемещение
     for y:=26 downto 2 do
      for x:=1 to 16 do
        if nap[x,y-1] then
         begin
            map[x, y]:=map[x, y-1];
            map[x, y-1]:=0;

            //звук
           soundX:=((x-8)-1)/6;
           SetSample3DPosition(fulpad, soundX, 0, 1.5);
           SetSampleVolume(fulpad, 95);
           PlaySample(fulpad);
         end;
   end;
end;

begin
   //очистка
   for x:=1 to 16 do
    for y:=1 to 26 do
     begin
        if pole.metki[x, y] then pole.map[x, y]:=0;
        pole.metki[x, y]:=false;
     end;

   for y:=1 to 25 do
     for x:=1 to 16 do
      if ((map[x, y]>0)) then Padenie(x, y);

   for x:=1 to 15 do
    for y:=1 to 25 do
     begin
        //горизонталь
       if ((pole.map[x, y]<>0) and (pole.map[x+1, y]<>0) and (pole.map[x, y]+pole.map[x+1, y]=10)) then
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
       if ((pole.map[x, y]<>0) and (pole.map[x, y+1]<>0) and (pole.map[x, y]+pole.map[x, y+1]=10)) then
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

    if (ss>rec) and (firstrec) then
     begin
        DisableTimer(gametimer); 
        DisableTimer(kbdtimer);
        {$IFDEF WINDOWS}
        MessageBox(0,'Новый рекорд!','Information',$2040);
        {$ELSE}
        writeln('Новый рекорд!');
        {$ENDIF}
        EnableTimer(gametimer); 
        EnableTimer(kbdtimer);
        firstrec:=false;
     end;

    if GameOver then
     begin
        DisableTimer(gameTimer); 
        DisableTimer(kbdTimer);
        {$IFDEF WINDOWS}
        MessageBox(0, 'Game over!', 'TeNRiS', $1010);
        MessageBox(0, PChar('Total score: '+IntToStr(ss)), 'Game over', $1020);
        res:=MessageBox(0, 'Play again?', 'TeNRiS', $2023);
        case res of
         6: begin
                   pole.Init;
                   figura.Load;
                   ss:=0;
                   EnableTimer(gameTimer); 
                   EnableTimer(kbdTimer);
                end;
         7: QuitEngine;
        end;
        {$ELSE}
        writeln('Game over! Score: ', ss);
        writeln('Play again? (y/n)');
        // Console input handling would go here
        {$ENDIF}
     end;
end;

{----------------}

procedure Free;
var f:integer;
begin
  //сохранить рекорды
  if ss>rec then begin
  f:=FileCreate('record.dat');
  if (f<>-1) and (ss>rec) then
   begin
      FileWrite(f, ss, SizeOf(ss));
      FileClose(f);
   end;
  end;
  {$IFDEF WINDOWS}
  MessageBox(0, 'Спасибо что играете в игры от NiCketT-software', 'TeNRiS', $1040);
  {$ENDIF}
end;

procedure Init;
var bmp1, bmp2:TBitmap; f:integer;
begin
  {$IFDEF WINDOWS}
  SendMessage(DGLEngineDLL_Handle, WM_SETICON, 1, LoadIcon(hInstance, 'MAINICON'));
  if not fullscrean then ShowCursor(True);
  {$ENDIF}
   //загрузка текстур
  fon:=LoadTextureFromFile(GetCurrentDir+'\texture\picture.jpg');
  font1:=LoadFontFromFile(GetCurrentDir+'\texture\font1.dft');
  font2:=LoadFontFromFile(GetCurrentDir+'\texture\font2.dft');
  font3:=LoadFontFromFile(GetCurrentDir+'\texture\font3.dft');
  bmp1:=TBitmap.Create;
  bmp1.LoadFromFile(GetCurrentDir+'\texture\logo.bmp');
  bmp2:=TBitmap.Create;
  {$IFDEF WINDOWS}
  bmp2.Handle:=LoadBitmap(hInstance,PChar('MASK'));
  {$ENDIF}
  logo:=LoadTexture(bmp1, TEXDETAIL_BEST, TRANSCOLOR_NONE, 1, bmp2);
  bmp1.Free;
  bmp2.Free;
  EnableTimer(gameTimer); 
  EnableTimer(kbdTimer);
  logo_transp:=0; 
  time:=1;
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
  if (f<>-1) then 
   FileRead(f, rec, SizeOf(rec))
  else 
   rec:=200; //по умолчанию
  FileClose(f);
  firstrec:=true;

  figura.Load;
  pole.Init; 
  testis:=false;
  ss:=0;
  ApplicationName('TeNRiS II');
end;

procedure Draw;
begin
  //смещение окна
  dx:=0;
  if fullscrean then dx:=Round((GetScreenResX-400)/2);
  Begin2D;
    DrawTexture2D_Simple(fon, dx+1 , 1, 400, 600); //фон
    DrawTexture2D(logo, dx+400-151 , 600-83, 150, 80, 0, logo_transp, $FFFFFF, false, false, false); //логотип

    //игровые объекты
    figura.Show;
    pole.show;

    DrawText2D(font2, dx+285, 20, 'Score: '+IntToStr(ss), $FF00FF, 255);
    DrawText2D(font3, dx+5, 5, 'top score: '+IntToStr(rec), $00FF00, 255);
  End2D;
end;

procedure Process;
begin
   //анимация логотипа
   if time>=1 then
    begin
       time:=time+1;
       if (time>=5) and (time<=55) then logo_transp:=5*(time-5); //появление
       if (time>130) and (time<=180) then logo_transp:=250-5*(time-130);
       if time>=3000 then time:=0;
    end;
end;

procedure gameProcess;
begin
   figura.mooving:=false;
   figura.Down(false);
   if testis then pole.Test;
   testis:=false;
end;

procedure KeyboardProcess;
var soundx:real;
begin
   //обработка клавиш
   if IsKeyPressed(key_up) then figura.Rot;
   if IsKeyPressed(Key_Left) then figura.Left;
   if IsKeyPressed(Key_Right) then figura.Right;
   if IsKeyPressed(Key_Space) then figura.Down(true);
   if IsKeyPressed(Key_Down) then begin
       //звук
       soundX:=((figura.sx-8)+0.5)/5;
       SetSample3DPosition(key_sound, soundX, figura.sy/26, 2);
       SetSampleVolume(key_sound, 95);
       PlaySample(key_sound);

       figura.Down(false);
       figura.Down(false);
       figura.Down(false);
   end;
   if IsKeyPressed(Key_Escape) then QuitEngine;
   if IsKeyPressed(Key_F1) then
   {$IFDEF WINDOWS}
   ShellExecute(0, PChar('open'), PChar('readme.txt'), nil, PChar(GetCurrentDir), SW_ShowNormal);
   {$ENDIF}
   if IsKeyPressed(Key_R) then begin
       pole.Init;
       figura.Load;
       ss:=0;
   end;
   if IsKeyPressed(Key_S) then begin
       if IsMusicPlaying then
        StopMusic
       else 
        PlayMusic(GetCurrentDir+'\sounds\crasy frog.mid',TRUE); 
   end;
end;

begin
 if LoadDGLEngineDLL('DGLEngine.dll') then
 begin
  RegProcedure(PROC_DRAW,@Draw);
  RegProcedure(PROC_PROCESS,@Process);
  RegProcedure(PROC_INIT,@Init);
  RegProcedure(PROC_FREE,@Free);

  //проверка параметров
  fullscrean:=false;
  if (ParamCount>=1) and (ParamStr(1)='fullscrean') then
   begin
      //включить полноэкранный режим
      fullscrean:=true;
      //настроить движок из ini-файла
      SetEngineInitParametrs(800, 600, 32, 85, true, false, true, true);
   end
   else 
    SetEngineInitParametrs(400, 600, 32, 0, false, false, false, true);

  SetGameProcessInterval(100);
  ApplicationName('TeNRiS. Loading...');
  kbdTimer:=AddTimer(25, @KeyboardProcess);
  gameTimer:=AddTimer(750, @gameProcess);
  PleaseNoLogo;
  EnableTimer(gameTimer);
  EnableTimer(kbdTimer);

  StartEngine;
  FreeDGLEngineDLL('TeNRiS.exe');
 end;
end.
