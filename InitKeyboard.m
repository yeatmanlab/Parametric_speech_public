function kb = InitKeyboard
% Setup universal Mac/PC keyboard and keynames
KbName('UnifyKeyNames');

kb.escKey = KbName('ESCAPE');
kb.oneKey = [KbName('1!'), KbName('1')];
kb.twoKey = [KbName('2@'), KbName('2')];
kb.threeKey = [KbName('3#'), KbName('3')];
kb.fourKey = [KbName('4$'), KbName('4')];
kb.fiveKey = [KbName('5%'), KbName('5')];
kb.sixKey = [KbName('6^'), KbName('6')];
kb.sevenKey = [KbName('7&'), KbName('7')];
kb.eightKey = [KbName('8*'), KbName('8')];
kb.nineKey = [KbName('9('), KbName('9')];
kb.zeroKey = [KbName('0)'), KbName('0')];

kb.qKey = KbName('q');
kb.wKey = KbName('w');
kb.eKey = KbName('e');
kb.rKey = KbName('r');
kb.spaceKey = KbName('space');
kb.pKey = KbName('p');
kb.oKey = KbName('o');
kb.iKey = KbName('i');
kb.kKey = KbName('k');
kb.lKey = KbName('l');
kb.zKey = KbName('z');
kb.xKey = KbName('x');
kb.cKey = KbName('c');
kb.aKey = KbName('a');
kb.sKey = KbName('s');
kb.dKey = KbName('d');
kb.fKey = KbName('f');
kb.nKey = KbName('n');
kb.hKey = KbName('h');

% Buttonbox keys
kb.tKey = KbName('t');
kb.yKey = KbName('y');
kb.bKey = KbName('b');
kb.gKey = KbName('g');
kb.rKey = KbName('r');

% Set proper keymapping
kb.triggerKey = kb.fiveKey;
kb.lrotKey = kb.yKey;
kb.rrotKey = kb.bKey;
kb.yesKey = kb.gKey;
kb.noKey = kb.rKey;

% Arrows
kb.leftKey = KbName('LeftArrow');
kb.rightKey = KbName('RightArrow');
kb.downKey = KbName('DownArrow');
kb.upKey = KbName('UpArrow');
kb.CTRL = KbName('LeftControl');

% Initialize KbCheck
[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1);
GetSecs;