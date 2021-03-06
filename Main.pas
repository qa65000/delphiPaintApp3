unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.StdCtrls, FMX.Controls.Presentation, FMX.Edit, FMX.EditBox,
  FMX.SpinBox;

type
  { Lineを表示するための位置への情報 sStart = 開始, sNext= 継続　, sEnd =終端 }
 TLineStatus = (sStart, sNext, sEnd);

  { Line 描画点、Status、レコード型(構造体)として定義}
  TLinePoint = record
          Positon : TPointF;
          Status  : TLineStatus;
          Color   : TAlphaColor;      { 色情報追加}
        Thickness : Integer;          { 線の太さ追加}
  end;
  PLinePoint = ^TLinePoint;

  TMainForm = class(TForm)
    Layout1: TLayout;
    PaintBox1: TPaintBox;
    ColorPalettePanel: TRectangle;
    Rectangle1: TRectangle;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    Rectangle4: TRectangle;
    Rectangle5: TRectangle;
    Rectangle6: TRectangle;
    Rectangle7: TRectangle;
    Rectangle8: TRectangle;
    SpinBox1: TSpinBox;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure SpinBox1Change(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
    procedure ColorClick(Sender: TObject);
  private
    DrawPoints  : TList<TLinePoint>;
    PressStatus : Boolean;
    SelectColor : TAlphaColor;       { 色情報追加 }
    SelectThickness : Integer;        { 線の太さ情報追加}
    procedure AddPoint(const x, y: single; const Status: TLineStatus; const Color: TAlphaColor ; const Thickness : Integer);          { 色/線の太さ情報追加 }
    { private 宣言 }
  public
    { public 宣言 }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}



procedure TMainForm.FormCreate(Sender: TObject);
begin
    DrawPoints := TList<TLinePoint>.Create;  { 描画点リストの構築 }
    SelectColor :=  TAlphaColorRec.Black;     { 初期色を黒とする }
    SelectThickness := SpinBox1.Text.ToInteger;     {　線の太さを設定 }
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  DrawPoints.DisposeOf;   { 描画点リストの破棄 }
end;

procedure TMainForm.addPoint(const x, y: single; const Status: TLineStatus; const Color: TAlphaColor ; const Thickness : Integer);          { 色/線の太さ情報追加 }
var
    TLP: TLinePoint;    { 仮Line Point }
begin
        if(DrawPoints.Count < 0 ) then exit;   { マイナスはあり得ない }
        TLP.Thickness := Thickness;             { 線の太さ情報追加 }
        TLP.Color   := Color;                  { 色データ設定 }
        TLP.Positon := PointF(x, y);           { 設定データ仮作成 }
        TLP.Status  := Status;                 { ラインステータスを保存 }
        DrawPoints.Add(TLP);                   { Listに追加 }
        PaintBox1.Repaint;                     { 再描画 }
end;

procedure TMainForm.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
     if ssLeft in Shift then      { 左ボタン押している？ }
     begin
       PressStatus := True;       { 左ボタン押し状態設定 }
       AddPoint( x, y ,sStart,SelectColor,SelectThickness);   {  ラインステータス:開始でリスト追加}
     end;
end;


procedure TMainForm.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
begin
     if ssLeft in Shift then      { 左ボタン押している？ }
     begin
       if(PressStatus =  True) then  { 押し検出済み?}
       AddPoint( x, y ,sNext,SelectColor,SelectThickness);   { ラインステータス:継続でリスト追加}
     end;
end;

procedure TMainForm.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
    if(PressStatus =  True) then  { 左ボタン押していた？ }
    begin
       AddPoint( x, y ,sEnd,SelectColor,SelectThickness);   { ラインステータス:終端でリスト追加}
    end;
    PressStatus := false;       {押し状態を解除}
end;

procedure TMainForm.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
var
   TLP: TLinePoint;    { 仮Line Point }
   StartPoint : TPointF;
begin
        if(DrawPoints.Count < 0 ) then exit;   { マイナスはあり得ない }

        Canvas.Stroke.Kind := TBrushKind.Solid;     {とりあえずのペン色や種類}
        Canvas.Stroke.Dash := TStrokeDash.Solid;
   //     Canvas.Stroke.Thickness := 2;
   //   Canvas.Stroke.Color := TAlphaColorRec.Black;

        {線を引く処理}

        for TLP in DrawPoints do
        begin
             case TLP.Status of
                        sStart : StartPoint := TLP.Positon;
                else
                        begin
                            Canvas.Stroke.Thickness := TLP.Thickness;    {線の太さ設定追加}
                            Canvas.Stroke.Color     := TLP.Color;      { 色情報設定追加 }
                            Canvas.DrawLine(StartPoint, TLP.Positon, 1,  Canvas.Stroke);
                            StartPoint := TLP.Positon;
                        end;
                end;
        end;
end;


procedure TMainForm.SpinBox1Change(Sender: TObject);
begin
    SelectThickness := SpinBox1.Text.ToInteger;
end;

procedure TMainForm.ColorClick(Sender: TObject);
begin
  SelectColor := (Sender as  TRectangle).Fill.Color;
end;

end.
