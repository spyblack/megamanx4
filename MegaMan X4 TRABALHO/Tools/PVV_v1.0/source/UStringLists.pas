unit	UStringLists;


//	Extended from "TObjectList" to use "TStringList" instead of "TObject".


interface  //-----------------------------------------------------------------------------------
uses	Classes, Contnrs;


type	TStringLists	=	class(TObjectList)
				private
				function  GetItem	(Index : Integer) : TStringList;
				procedure SetItem	(Index : Integer;  AObject : TStringList);
				public
				function  Add		(AObject : TStringList) : Integer;
				function  Remove	(AObject : TStringList) : Integer;
				function  IndexOf	(AObject : TStringList) : Integer;
				procedure Insert	(Index : Integer;  AObject : TStringList);
				property  Items		[Index : Integer] : TStringList  read GetItem  write SetItem;  default;
				end;


implementation  //------------------------------------------------------------------------------


function TStringLists.Add(AObject : TStringList) : Integer;
begin
Result := inherited Add(AObject);
end;


function TStringLists.Remove(AObject : TStringList) : Integer;
begin
Result := inherited Remove(AObject);
end;


function TStringLists.IndexOf(AObject : TStringList) : Integer;
begin
Result := inherited IndexOf(AObject);
end;


procedure TStringLists.Insert(Index : Integer;  AObject : TStringList);
begin
inherited Insert(Index, AObject);
end;


function TStringLists.GetItem(Index : Integer) : TStringList;
begin
tObject(Result) := inherited GetItem(Index);
end;


procedure TStringLists.SetItem(Index : Integer;  AObject : TStringList);
begin
inherited SetItem(Index, AObject);
end;


//----------------------------------------------------------------------------------------------


end.
