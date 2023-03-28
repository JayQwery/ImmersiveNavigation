Scriptname INQuestScript extends Quest  

GlobalVariable property QETEffectTimesFired auto 

;Custom function to subtract 
int function oneLess(int index, int sub) 
    int counter = sub
    int loopNum =0
    int EndIndex = 0
    While (counter<index)
        counter+=1
        loopNum+=1
        EndIndex=loopNum
    EndWhile
        return EndIndex
EndFunction 

String Function getRelativeLoc(String Ref,String hold)
    String relLoc
    String cardinal

    String cmd2 = "prid "+Ref
    ConsoleUtil.ExecuteCommand(cmd2)
    ConsoleUtil.ExecuteCommand("getpos x")
    String posxString = ConsoleUtil.ReadMessage()
    ConsoleUtil.ExecuteCommand("getpos y")
    String posyString = ConsoleUtil.ReadMessage()
    int posx = StringUtil.Substring(posxString,12,0) as int
    int posy = StringUtil.Substring(posyString,12,0) as int
    
    ; Debug.MessageBox("posx: "+posx+" posy: "+posy)
    int ns
    int ew 
    if(hold == "player")
        ConsoleUtil.ExecuteCommand("prid player")
        ConsoleUtil.ExecuteCommand("getpos y")
        String pposyString = ConsoleUtil.ReadMessage()
        ConsoleUtil.ExecuteCommand("getpos x")
        String pposxString = ConsoleUtil.ReadMessage()

        int pposx = StringUtil.Substring(pposxString,12,0) as int
        int pposy = StringUtil.Substring(pposyString,12,0) as int
        ; Debug.MessageBox("pposx: "+pposx+" pposy: "+pposy)
        ns = pposy
        ew = pposx 
    elseif(hold == "Whiterun")
        ;northsouth is y, ew is x
        ns = -7424
        ew = 19312
    elseif(hold =="Solitude")
        ns = 104333
        ew = -65881 
    elseif(hold =="Riften")
        ns = -92074
        ew = 174310
    elseif(hold =="Winterhold")
        ns = 111646
        ew = 114359
    elseif(hold =="Falkreath")
        ns = -87534
        ew = -29417
    elseif(hold =="Markarth")
        ns = 5440
        ew = -173272
    EndIF
    ;whiterun test (19312,-7424)
    if posy > ns
        cardinal = "North"
    else 
        cardinal = "South"
    EndIf

    if posx > ew
        cardinal = cardinal+" East"
    else 
        cardinal = cardinal +" West"
    EndIf

    relLoc = ("Your Quest is "+cardinal+" of here")
    return relLoc 
EndFunction 

Function INMain()
    ;Tracks the number of times the spell has been cast
    QETEffectTimesFired.SetValueInt(QETEffectTimesFired.GetValueInt()+1)
    ; Creates a unique id so the script reads the new "show quest targets"
    String sqtUnique = "UniqueSQT"+QETEffectTimesFired.GetValueInt()
    ConsoleUtil.PrintMessage(sqtUnique)
    ConsoleUtil.ExecuteCommand("showquesttargets")

    ;gets the console text, finds my unique id, and gets the text after the custom id
    string consoleText = UI.GetString("Console","_global.Console.ConsoleInstance.CommandHistory.text")
    int consoleTextSearchIndex = StringUtil.Find(consoleText,sqtUnique)
    consoleText = StringUtil.Substring(consoleText,consoleTextSearchIndex,0)

    ;gets the first curret quest listed by sqt
    int questIDIndex = StringUtil.Find(consoleText,"Current Quest: ")
    String questSQT = StringUtil.Substring(consoleText,questIDIndex+15,0)
 
    ;gets index to trim text
    int questIDEndIndex = StringUtil.Find(questSQT," ")
    int EndIndex = oneLess(questIDEndIndex,2)
    
    ;isolates questID
    String questID = StringUtil.Substring(questSQT,0,EndIndex)
    int counter=0
    int loopint=256
    int nxtQuestIndex
    ;if quest is not active, finds first active quest
    if Quest.GetQuest(questID).isActive()
    Else
        while(counter<loopint)
            counter+=1
            ;gets next quest in console text
            nxtQuestIndex = StringUtil.Find(questSQT,"Current Quest: ")
            questSQT = StringUtil.Substring(questSQT,nxtQuestIndex+15,0)
            questIDEndIndex = StringUtil.Find(questSQT," ")
            EndIndex = oneLess(questIDEndIndex,2)
            questID = StringUtil.Substring(questSQT,0,EndIndex)

            ;if new quest is active ends loop
            if Quest.GetQuest(questID).isActive()
                counter=loopint
            EndIF
        EndWhile
    EndIF


    ;trims out "current quest"
    String questSQTargets = StringUtil.Substring(questSQT,0,0)
    int sqtENDIndex = StringUtil.Find(questSQTargets,"Current Quest: ")
    questSQTargets = StringUtil.Substring(questSQTargets,0,sqtENDIndex)

    ;gets/isolates load door id
    int sLoadDoorIndex = StringUtil.Find(questSQTargets,"load door:")
    String sDoor = StringUtil.Substring(questSQTargets,sLoadDoorIndex,0)    
    sLoadDoorIndex = StringUtil.Find(sDoor,":")
    sDoor = StringUtil.Substring(sDoor,sLoadDoorIndex+4,8)
    ; Debug.MessageBox("sdoor: "+sDoor)
    if sdoor == "me cell/"
        sLoadDoorIndex = StringUtil.Find(questSQTargets,"Reference:")
        sDoor = StringUtil.Substring(questSQTargets,sLoadDoorIndex,0)   
        sLoadDoorIndex = StringUtil.Find(sDoor,":")
        sDoor = StringUtil.Substring(sDoor,sLoadDoorIndex+4,8)
    EndIf 
    ; teleports player to quest
    ; String cmd1 = "player.moveto "+sDoor
    ; ConsoleUtil.ExecuteCommand(cmd1)

    Debug.MessageBox(getRelativeLoc(sDoor,"player"))
EndFunction 