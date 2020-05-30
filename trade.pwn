#define FILTERSCRIPT
#include <a_samp>
#include <a_graphfunc>
#include <zcmd>
#include <sscanf2>

#define MAX_POINTS 230

new Text:TDEditor_PTD[MAX_PLAYERS][1];

enum pdata
{
	showing,
	moneyput,
 	Float:put,
 	buy,
}
new pData[MAX_PLAYERS][pdata];

enum pdta
{
	Float:val
}
new Graph:MY_GRAPH;
new pointData[MAX_POINTS][pdta];
new count = 0;

new Float:IncDec[][1] = {
	{1.045}, {2.042}, {-1.045}, {-2.042}, {1.234}, {-1.234}, {-0.124}, {0.124}
};

forward InitializeTD(playerid, str[]);
public InitializeTD(playerid, str[])
{
	TDEditor_PTD[playerid][0] = TextDrawCreate(315.768646, 246.101257, str);
	TextDrawLetterSize( TDEditor_PTD[playerid][0], 0.398000, 1.590000);
	TextDrawTextSize(TDEditor_PTD[playerid][0], 0.000000, 200.000000);
	TextDrawAlignment(TDEditor_PTD[playerid][0], 2);
	TextDrawColor(TDEditor_PTD[playerid][0], -1);
	TextDrawUseBox(TDEditor_PTD[playerid][0], 1);
	TextDrawBoxColor( TDEditor_PTD[playerid][0], 255);
	TextDrawSetShadow(TDEditor_PTD[playerid][0], 0);
	TextDrawSetOutline(TDEditor_PTD[playerid][0], 0);
	TextDrawBackgroundColor(TDEditor_PTD[playerid][0], 255);
	TextDrawFont( TDEditor_PTD[playerid][0], 1);
	TextDrawSetProportional( TDEditor_PTD[playerid][0], 1);
	TextDrawSetShadow(TDEditor_PTD[playerid][0], 0);
}


main() { }

public OnFilterScriptInit() {
    AddPlayerClass(0, 0, 0, 0, 0, 0, 0, 0 ,0 , 0 ,0);
    for(new i = 0; i < MAX_POINTS; i++)
    {
	    if(i == 0) pointData[i][val] = 1.0;
	    else if(i == MAX_POINTS - 1) pointData[i][val] = pointData[i-1][val];
	    else if(i > 150) pointData[i][val] = pointData[i-1][val] + 0.01;
	    else pointData[i][val] = pointData[i-1][val] + 1.0;
	}
    MY_GRAPH = GRAPHIC::Create(200.0, 250.0, 0, 0, 230, 230);
	GRAPHIC::XYAxisColor(MY_GRAPH, 0x000000FF, 0x000000FF);

	GRAPHIC::UseBackground(MY_GRAPH, 1);
	GRAPHIC::BackgroundColor(MY_GRAPH, 0x000000FF);
	
    SetTimer("ChangeVals", 1500, true);
    
}

CMD:trade(playerid, params[])
{
	new money, bbuy[24], mstr[256];
	if(sscanf(params, "is[24]", money, bbuy)) return SendClientMessage(playerid, -1, "[USAGE] /trade [MONEY] [Buy/Sell]");
	if(money < 0) return SendClientMessage(playerid, -1, "[ERROR] Money must be positive.");
	if(!strcmp(bbuy, "buy", true, 3))
	{
	    pData[playerid][moneyput] = money;
		pData[playerid][put] = pointData[MAX_POINTS - 1][val];
		GivePlayerMoney(playerid, -money);
		pData[playerid][buy] = 1; // buy
		format(mstr, 256, "You have put on buy at %f", pData[playerid][put]);
		SendClientMessage(playerid, -1, mstr);
	}
	else if(!strcmp(bbuy, "sell", true, 4))
	{
	    pData[playerid][moneyput] = money;
		pData[playerid][put] = pointData[MAX_POINTS - 1][val];
		GivePlayerMoney(playerid, -money);
		pData[playerid][buy] = 2; // buy
		format(mstr, 256, "You have put on sell at %f", pData[playerid][put]);
		SendClientMessage(playerid, -1, mstr);
	}
	else SendClientMessage(playerid, -1, "ERROR");
	return 1;
}

CMD:stoptrade(playerid, params[])
{
	if(pData[playerid][moneyput] == 0) return SendClientMessage(playerid, -1, "ERROR");
	new Float:diff;
	if(pData[playerid][buy] == 1) diff = pointData[MAX_POINTS-1][val] - pData[playerid][put];
	else if(pData[playerid][buy] == 2) diff = pData[playerid][put] - pointData[MAX_POINTS - 1][val];
	new multi = floatround(diff);
	GivePlayerMoney(playerid, multi*pData[playerid][moneyput]);
	new mstr[256];
	format(mstr, 256, "You have earned %i.", multi*pData[playerid][moneyput]);
	SendClientMessage(playerid, -1, mstr);
	pData[playerid][moneyput] = 0;
	pData[playerid][put] = 0;
	pData[playerid][buy] = 0;
	return 1;
}

CMD:tradechart(playerid, params[])
{
	if(pData[playerid][showing] == 0)
	{
	    GRAPHIC::ShowForPlayer(playerid, MY_GRAPH);
	    TextDrawShowForPlayer(playerid, TDEditor_PTD[playerid][0]);
		pData[playerid][showing] = 1;
	}
	else
	{
	    GRAPHIC::HideForPlayer(playerid, MY_GRAPH);
	    TextDrawHideForPlayer(playerid, TDEditor_PTD[playerid][0]);
		pData[playerid][showing] = 0;
	}
	
	return 1;
}


/*native Graph:GRAPHIC::Create(Float:x, Float:y, Float:x_min, Float:y_min, Float:x_max, Float:y_max);
native GRAPHIC::XYAxisColor(Graph:_id, _x_color, _y_color);
native GRAPHIC::UseBackground(Graph:_id, use);
native GRAPHIC::BackgroundColor(Graph:_id, color);
native GRAPHIC::GRAPHIC::AddPoint(Graph:_id, Float:x, Float:y, color);
native GRAPHIC::ShowForPlayer(playerid, Graph:_id);
native GRAPHIC::HideForPlayer(playerid, Graph:_id);
native GRAPHIC::ShowForAll(Graph:_id);
native GRAPHIC::HideForAll(Graph:_id);
native GRAPHIC::Update(Graph:_id, playerid = INVALID_PLAYER_ID);
native GRAPHIC::Destroy(Graph:_id);
native GRAPHIC::OtherXYAxis(oper, playerid, Graph:_id, xAxis, yAxis);*/

public
	OnPlayerSpawn(playerid)
{
	//GRAPHIC::ShowForPlayer(playerid, MY_GRAPH);
	InitializeTD(playerid, "Nothing");
	return 1;
}

forward ChangeVals();
public ChangeVals()
{
    GRAPHIC::RemoveTD(MAX_POINTS);
    for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	    {
     		TextDrawDestroy(TDEditor_PTD[i][0]);
	    }
	}

	GRAPHIC::Destroy(MY_GRAPH);
    MY_GRAPH = GRAPHIC::Create(200.0, 250.0, 0, 0, 230, 230);
    GRAPHIC::XYAxisColor(MY_GRAPH, 0x000000FF, 0x000000FF);

	GRAPHIC::UseBackground(MY_GRAPH, 1);
	GRAPHIC::BackgroundColor(MY_GRAPH, 0x000000FF);
	new Float:exps;
	new Float:oldshit = pointData[MAX_POINTS-1][val];
	for(new i = 0; i < MAX_POINTS; i++)
	{
		exps = IncDec[random(sizeof(IncDec))][0];
	    if(i == MAX_POINTS - 1) pointData[i][val] = pointData[i][val] + exps;
	    else pointData[i][val] = pointData[i+1][val];
	    if(pointData[i][val] < 0.0) pointData[i][val] = 0.0;
	    if(pointData[i][val] > 229.0) pointData[i][val] = 229.0;
	    if(i < 0 || i > MAX_POINTS-1) continue;
	    GRAPHIC::AddPoint(MY_GRAPH, i,  pointData[i][val], 0xFFFFFFFF);
		count++;
		printf("called %i: %f", count, pointData[i][val]);
	}
	new Float:newshit = pointData[MAX_POINTS - 1][val];
	new Float:diff = newshit - oldshit;
	new mstr[256];
	if(diff >= 0) format(mstr, 256, "      New: %f     Diff:~g~%f", newshit, diff);
	else format(mstr, 256, "      New: %f     Diff:~r~%f", newshit, diff);
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
	    if(IsPlayerConnected(i))
	    {
	        if(pData[i][showing] == 1)
			{
			    GRAPHIC::ShowForPlayer(i, MY_GRAPH);
				InitializeTD(i, mstr);
				TextDrawShowForPlayer(i, TDEditor_PTD[i][0]);
			}
	    }
	}
	GRAPHIC::ResetTD();
}
