Scriptname INQuestScript extends Quest  

; GlobalVariable property QETEffectTimesFired auto 

Function INMain()
    ; Debug.MessageBox("QetEffect: "+QETEffectTimesFired.GetValueInt())
    String questSQT = getSQT()
    ; Debug.MessageBox("qst:" +questSQT)
    String ActiveQID = getActiveQuest(questSQT)

    String[] targets = new string[128]
    targets = getTargets(questSQT,ActiveQID)

    ; ; Debug.MessageBox("trgt:"+targets)
    String[] relLoc = getRID(targets)

    String msg 
    if relLoc.Length == 1 
        msg = ("The place you are looking for is "+targets[0]+" of here")
    else
        msg = ("It seems the things you are looking for can't be found in one place")
        int counter = 0 
        While(counter < relLoc.Length)
            if relLoc[counter] 
                Debug.Trace("does this reloc exsist?")
                int counterNUM = counter+1
                String Nth
                if counterNUM == 1 
                    Nth = "st"
                elseif counterNUM == 2
                    Nth = "nd"
                elseif counterNUM == 3
                    Nth = "rd" 
                else 
                    Nth = "th"
                EndIF 
                msg += ("\n"+"The "+counterNUM+Nth+" location is "+relLoc[counter])
                ; ; Debug.MessageBox("reloc: "+relLoc[counter] +" co: "+counter)
            else
                counter = relLoc.Length
            EndIF 
            counter+=1
        EndWhile 
        ; ; Debug.MessageBox(msg)
    EndIF 

EndFunction 

function printArray(String[] testArray)
    int counter = 0
    if testarray.Length == 0
        Debug.trace("array is empty")
    endIF 
    While(counter < testArray.Length)
        Debug.Trace("array: "+testArray[counter])
        counter+=1 
    EndWhile 
EndFunction 

String Function getSQT()
    ;Tracks the number of times the spell has been cast
    ; QETEffectTimesFired.SetValueInt(QETEffectTimesFired.GetValueInt()+1)
    ; Creates a unique id so the script reads the new "show quest targets"
    ; String sqtUnique = "UniqueSQT"+QETEffectTimesFired.GetValueInt()
    ; ConsoleUtil.PrintMessage(sqtUnique)


    ;clear console = run the command sqt - clear console
    UI.SetString("Console","_global.Console.ConsoleInstance.CommandHistory.text"," ")
    ConsoleUtil.ExecuteCommand("showquesttargets")
    string questSQT = UI.GetString("Console","_global.Console.ConsoleInstance.CommandHistory.text")
    ; int consoleTextSearchIndex = StringUtil.Find(consoleText,sqtUnique)
    ; consoleText = StringUtil.Substring(consoleText,consoleTextSearchIndex,0)

    ;gets the first curret quest listed by sqt
    ; int questIDIndex = StringUtil.Find(consoleText,"Current Quest: ")
    ; String questSQT = StringUtil.Substring(consoleText,questIDIndex+15,0)
    UI.SetString("Console","_global.Console.ConsoleInstance.CommandHistory.text"," ")
    return questSQT
EndFunction 


String Function getActiveQuest(String questSQT)
    int counter=0
    int loopint=256
    int nxtQuestIndex
    ; ; Debug.MessageBox("gaq qid (bl):"+questID)
    ; ; ; Debug.MessageBox("questID1:" +questID)
    ; ; Debug.MessageBox("sqt: "+questsqt)
    String QuestID = getQuestID(questSQT)
    if Quest.GetQuest(questID).isActive()
        return questID
    Else
        while(counter<loopint)
            counter+=1
            ;gets next quest in console text
            nxtQuestIndex = StringUtil.Find(questSQT,"Current Quest: ")
            questSQT = StringUtil.Substring(questSQT,nxtQuestIndex+15,0)
            questID = getQuestID(questSQT)

            ;if new quest is active ends loop
            if Quest.GetQuest(questID).isActive()
                counter=loopint
                ; Debug.MessageBox("gaq qid (al):"+questID)
                return questID
            EndIF 
        EndWhile
    EndIF
EndFunction 

String Function getQuestID(String questSQT)
    ;gets index to trim text
    int questIDEndIndex = StringUtil.Find(questSQT," ")
    int EndIndex = oneLess(questIDEndIndex,2)
    
    ;isolates questID
    String questID = StringUtil.Substring(questSQT,0,EndIndex)
    ; ; Debug.MessageBox("QuestID: "+questID)
    return questID
EndFunction 

String[] Function getTargets(String questSQT,String QID)
    Debug.MessageBox("sqt: "+questSQT)
    ;
    int QIDindex = StringUtil.Find(questSQT,QID)
    String questSQTargets = StringUtil.Substring(questSQT,QIDindex,0)
    int sqtENDIndex = StringUtil.Find(questSQTargets,"Current Quest: ")
    questSQTargets = StringUtil.Substring(questSQTargets,0,sqtENDIndex)

    Debug.MessageBox("targets1:"+questSQTargets)
    String[] targets = new String[128]
    targets = TargetsToArray(questSQTargets, QID)
    return targets
EndFunction 

String[] Function TargetsToArray(String questSQTargets, String QID)
    ;get the num of objectives 
    int qidIndex = StringUtil.Find(questSQTargets,QID)
    int currentTargetIndex = StringUtil.Find(questSQTargets,"Current Targets",qidIndex)
    ; int currentTargetNum = oneLess(currentTargetIndex,2)
    String NumTargets = StringUtil.SubString(questSQTargets,currentTargetIndex+15,0)
    Debug.MessageBox("num of target: "+NumTargets)

    ;fill the array 
    String[] targets = new String[128]
    int counter = 0 
    ; while(counter < NumTargets)  
    ;     int index = counter+1
    ;     String FindString = "Target "+index
    ;     int targetIndex = StringUtil.Find(questSQTargets,FindString)
    ;     String target = StringUtil.Substring(questSQTargets,targetIndex,64)
    ;     targets[counter] = target
    ;     ; ; Debug.MessageBox("target"+target)
    ;     counter+=1
    ; EndWhile 
    ; return targets 
EndFunction 

String [] Function getRID(String[] targets)
    String[] relLoc = new String[128]
    int counter = 0
    while(counter < targets.Length)
        if targets[counter]
            String target = targets[counter]
            ;gets/isolates load door id
            ; Debug.MessageBox("grid targets: "+target)
            int sLoadDoorIndex = StringUtil.Find(target,"load door:")
            String sDoor = StringUtil.Substring(target,sLoadDoorIndex,0) 
            sLoadDoorIndex = StringUtil.Find(sDoor,":")
            sDoor = StringUtil.Substring(sDoor,sLoadDoorIndex+4,8)
            ; ; ; Debug.MessageBox("sdoor: "+sDoor)
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

    ; ; ; Debug.MessageBox("Ref: "+ref)
    ;select the passed in ref, then get it's x and y position 
    String cmd = "prid "+Ref
    ConsoleUtil.ExecuteCommand(cmd)
    ConsoleUtil.ExecuteCommand("getpos x")
    int posx = StringUtil.Substring(ConsoleUtil.ReadMessage(),12,0) as int
    ConsoleUtil.ExecuteCommand("getpos y")
    int posy = StringUtil.Substring(ConsoleUtil.ReadMessage(),12,0) as int
    ; ; ; Debug.MessageBox("posx: "+posx+" posy: "+posy)
    
    ; ; Debug.MessageBox("posx: "+posx+" posy: "+posy)
    ConsoleUtil.ExecuteCommand("prid player")
    ConsoleUtil.ExecuteCommand("getpos y")
    int pposy = StringUtil.Substring(ConsoleUtil.ReadMessage(),12,0) as int
    ConsoleUtil.ExecuteCommand("getpos x")
    int pposx = StringUtil.Substring(ConsoleUtil.ReadMessage(),12,0) as int
    ; ; Debug.MessageBox("pposx: "+pposx+" pposy: "+pposy)


    ;whiterun test (19312,-7424)
    if posy > pposy
        cardinal = "North"
    else 
        cardinal = "South"
    EndIf

    if posx > pposx
        cardinal = cardinal +" west"
    else 
        cardinal = cardinal+" east"
    EndIf
    return cardinal 
EndFunction