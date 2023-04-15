Scriptname INQuestScript extends Quest  

GlobalVariable property QETEffectTimesFired auto 

Function INMain()
    String questSQT = getSQT()
    String questID = getQuestID(QuestSQT)
    String ActiveQID = getActiveQuest(questID,questSQT)
    String[] targets = new string[128]
    targets = getTargets(questSQT)

    getRID(targets)

    if targets.Length == 1 
        Debug.Trace("The place you are looking for is "+targets[0]+" of here")
    else
        Debug.Trace("It seems the things you are looking for can't be found in one place")
        int counter = 0 
        While(counter < targets.Length)
            if targets[counter] 
                Debug.Trace("Obj"+counter+": "+targets[counter])
            else
                counter = targets.Length
            EndIF 
            counter+=1
        EndWhile 
    EndIF 

EndFunction 

String Function getSQT()
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
    return questSQT
EndFunction 

String Function getQuestID(String questSQT)
    ;gets index to trim text
    int questIDEndIndex = StringUtil.Find(questSQT," ")
    int EndIndex = oneLess(questIDEndIndex,2)
    
    ;isolates questID
    String questID = StringUtil.Substring(questSQT,0,EndIndex)
    return questID
EndFunction 

String Function getActiveQuest(String questID,String questSQT)
    int counter=0
    int loopint=256
    int nxtQuestIndex

    if Quest.GetQuest(questID).isActive()
    Else
        while(counter<loopint)
            counter+=1
            ;gets next quest in console text
            nxtQuestIndex = StringUtil.Find(questSQT,"Current Quest: ")
            questSQT = StringUtil.Substring(questSQT,nxtQuestIndex+15,0)
            int questIDEndIndex = StringUtil.Find(questSQT," ")
            int EndIndex = oneLess(questIDEndIndex,2)
            questID = StringUtil.Substring(questSQT,0,EndIndex)

            ;if new quest is active ends loop
            if Quest.GetQuest(questID).isActive()
                counter=loopint
                return questID
            EndIF
        EndWhile
    EndIF
EndFunction 

String[] Function getTargets(String questSQT)
     ;trims out "current quest"
     String questSQTargets = StringUtil.Substring(questSQT,0,0)
     int sqtENDIndex = StringUtil.Find(questSQTargets,"Current Quest: ")
     questSQTargets = StringUtil.Substring(questSQTargets,0,sqtENDIndex)
 
     ;hijack the code to get the num of objectives 
     Debug.Trace("full sqt: "+questSQTargets)
     int currentTargetIndex = StringUtil.Find(questSQTargets,"Current Targets")
     int currentTargetNum = oneLess(currentTargetIndex,2)
     
     String NumTargets = StringUtil.SubString(questSQTargets,currentTargetNum,2)
     Debug.Trace("ct: "+NumTargets)
 
     Debug.Trace("numtarget: "+NumTargets)
 
 
     String[] targets = new String[128]
     targets = TargetsToArray(questSQT,NumTargets as Int)
     int counter2 = 0
     while(counter2 < targets.Length)
         counter2+=1
         Debug.Trace("lt: "+targets[counter2])
     EndWhile 

     return targets
EndFunction 

String[] Function TargetsToArray(String sqtString, Int NumTargets)

    String[] targets = new String[128]
    int counter = 0 
    while(counter < NumTargets)
        if targets[counter] 
            counter+=1
            String FindString = "Target "+counter
            int targetIndex = StringUtil.Find(sqtString,FindString)
            String target = StringUtil.Substring(sqtString,targetIndex,64)
            Debug.Trace("target "+counter+": "+target)
            targets[counter] = target
        else 
            counter = NumTargets
        EndIF 
    EndWhile 

    return targets 
EndFunction 

String [] Function getRID(String[] targets)
    String[] relLoc = new String[128]
    int counter = 0
    while(counter < targets.Length)
        if targets[counter]
            String target = targets[counter]
            ;gets/isolates load door id
            int sLoadDoorIndex = StringUtil.Find(target,"load door:")
            String sDoor = StringUtil.Substring(target,sLoadDoorIndex,0)    
            sLoadDoorIndex = StringUtil.Find(sDoor,":")
            sDoor = StringUtil.Substring(sDoor,sLoadDoorIndex+4,8)
            ;if load door = same cell. use the ref id instead
            if sdoor == "me cell/"
                sLoadDoorIndex = StringUtil.Find(target,"Reference:")
                sDoor = StringUtil.Substring(target,sLoadDoorIndex,0)   
                sLoadDoorIndex = StringUtil.Find(sDoor,":")
                sDoor = StringUtil.Substring(sDoor,sLoadDoorIndex+4,8)
            EndIf 
            relLoc[counter] = getRelativeLoc(sDoor)
            counter+=1 
        else 
            counter = targets.Length
        EndIF 
    EndWhile 
    return relLoc 
EndFunction 

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

String Function getRelativeLoc(String Ref)
    String cardinal

    ;select the passed in ref, then get it's x and y position 
    String cmd = "prid "+Ref
    ConsoleUtil.ExecuteCommand(cmd)
    ConsoleUtil.ExecuteCommand("getpos x")
    int posx = StringUtil.Substring(ConsoleUtil.ReadMessage(),12,0) as int
    ConsoleUtil.ExecuteCommand("getpos y")
    int posy = StringUtil.Substring(ConsoleUtil.ReadMessage(),12,0) as int
    
    ; Debug.MessageBox("posx: "+posx+" posy: "+posy)
    ConsoleUtil.ExecuteCommand("prid player")
    ConsoleUtil.ExecuteCommand("getpos y")
    int pposy = StringUtil.Substring(ConsoleUtil.ReadMessage(),12,0) as int
    ConsoleUtil.ExecuteCommand("getpos x")
    int pposx = StringUtil.Substring(ConsoleUtil.ReadMessage(),12,0) as int

    ;whiterun test (19312,-7424)
    if posy > pposy
        cardinal = "North"
    else 
        cardinal = "South"
    EndIf

    if posx > pposx
        cardinal = cardinal+" East"
    else 
        cardinal = cardinal +" West"
    EndIf
    return cardinal 
EndFunction