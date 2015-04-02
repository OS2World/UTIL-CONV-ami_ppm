program ami_ppm;

// Veit Kannegieser 2004.08.25

uses
  Dos,
  Objects,
  VpUtils;

var
  p                     :pByteArray;
  d                     :file;
  a                     :text;
  l,i                   :longint;
  z                     :string;
  Dir                   :DirStr;
  Name                  :NameStr;
  Ext                   :ExtStr;
  rc                    :integer;
  hdr1                  :
    packed record
      signature         :array[0..3] of char;
      b04               :byte;
      b05               :byte;
      hdrlen1           :smallword;
    end;
  hdr2                  :
    packed record
      u8                :longint;
      hdrlen2           :smallword;
      u0e               :smallword;
      u10               :smallword;
      x                 :smallword;
      y                 :smallword;
      u16               :smallword;
      u18               :smallword;
      colours           :smallword;
      u1c               :byte;
      signature2        :array[0..2] of char;
      pal               :array[0..15,1..3] of byte;
    end;
  zeilenlaenge          :longint;


function fa(b:byte):string;
  begin
    fa:=Int2Str(hdr2.pal[b,1])+' '
       +Int2Str(hdr2.pal[b,2])+' '
       +Int2Str(hdr2.pal[b,3])+' ';
  end;

begin

  if (ParamCount<1) or (ParamCount>2) or (ParamStr(1)='/?') or (ParamStr(2)='-?') then
    begin
      WriteLn('Usage: AMI_PPM <AMI Graphic source file> [ <target.ppm> ]');
      Halt(1);
    end;

  Assign(d,ParamStr(1));
  FileMode:=$40;
  {$I-}
  Reset(d,1);
  {$I+}
  rc:=IOResult;
  if rc<>0 then
    begin
      WriteLn('Can not open source file.');
      RunError(rc);
    end;
  BlockRead(d,hdr1,SizeOf(hdr1));
  if hdr1.signature<>'GRFX' then
    RunError(99);
  Seek(d,hdr1.hdrlen1);
  BlockRead(d,hdr2,SizeOf(hdr2));
  if hdr2.signature2<>'IMA' then
    RunError(99);
  if hdr2.colours>$10 then
    RunError(99);
  Seek(d,hdr1.hdrlen1+hdr2.hdrlen2);
  zeilenlaenge:=(hdr2.x+1) shr 1;
  l:=zeilenlaenge*hdr2.y;
  GetMem(p,l);
  BlockRead(d,p^,l);
  Close(d);

  if ParamCount=1 then
    begin
      FSplit(ParamStr(1),Dir,Name,Ext);
      Assign(a,Dir+Name+'.ppm');
    end
  else
    Assign(a,ParamStr(2));
  {$I-}
  Rewrite(a);
  {$I+}
  rc:=IOResult;
  if rc<>0 then
    begin
      WriteLn('Can not create output file.');
      RunError(rc);
    end;
  WriteLn(a,'P3');
  WriteLn(a,hdr2.x,' ',hdr2.y);
  WriteLn(a,63);
  z:='';
  for i:=0 to l-1 do
    begin
      z:=z+fa(p^[i] shr 4)+fa(p^[i] and $0f);
      if Length(z)>240-20 then
        begin
          WriteLn(a,z);
          z:='';
        end;
    end;
  if z<>'' then
    begin
      WriteLn(a,z);
      z:='';
    end;
  Close(a);
  Dispose(p);
end.

