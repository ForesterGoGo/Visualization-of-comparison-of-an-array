import processing.sound.*;

int listmem[] = {1,2,3,4,5,7,10,20,50,80,100}; 
int currentMem = 0;

int members = 1; // Количество значений в массиве
int toFPS = 30; // Минимальное количество фпс при котором будет производится отпимальное вычисление

IntList graphCount;
  
double mem2; //количество возможных положений

boolean flagPause = false;

int mas[]; // Главный массив
int count; // Количество случаев совпадения значения массива с значением его места
long frame; // Количество кадров в которых производился одно сравнение
long lastCompare = 0; // Номер кадра, при котором произошло одно положительное сравнение
int fps; // Количество кадров в секунду
int funcCount; // Динамическое количество функций вычисления
int minFrameToOneCompare; // Минимальное количество кадров, за которое произошло одно положительное сравнение

//---DRAW

float widthRect; // Ширина столбов, помещаемых в длину кадра
float heightRect; // Длина столба на единицу значения из массива
float graphWidthPoint = 0;
double graphHeightPoint;
String compareMas = "";

int currentTimeFind = 0;
int timeFind = 0;//int(toFPS*0.5);

Sound s;
SinOsc sinf;
void keyPressed()
{
  if(currentMem<10 && keyCode == 39) reStart(listmem[++currentMem]);
  if(currentMem>0 && keyCode == 37) reStart(listmem[--currentMem]);
  if(keyCode == 32) flagPause = !flagPause;
}
void reStart(int mem)
{
  members = mem;
  mem2 = (long)pow(mem,mem);
  mas = new int[mem];
  count = 0;
  frame = 0;
  funcCount = 200;
  minFrameToOneCompare = 1000000000;
  
  graphCount = new IntList();
  
  for(int i=0;i<mem;i++) mas[i] = i;
  widthRect = width/mem;
  heightRect = height/2/mem;
  graphHeightPoint = height/2/(mem2*2);
  compareMas = "[ ";
  for(int i=0;i<mem;i++) compareMas+=i+" ";
  compareMas += "]";
}
void setup() 
{
  size(1280, 720);
  noStroke();
  background(204);
  noCursor();
  sinf = new SinOsc(this);
  sinf.amp(0.1); // 0 to 1.0
  //sinf.play(200, 0.2);
  
  reStart(members);
}
boolean test() // Сравнение созданого набора чисел
{
  for(int i=0;i<members;i++) if(mas[i] != i) return false;
  return true;
}
boolean func() // Создание нового набора чисел
{
  boolean result = false;
  for(int i=0;i<members;i++) mas[i] = int(random(members));
  if(test()) 
  {
    count++;
    if(graphCount.size()>=25) graphCount.remove(0);
    graphCount.append(int(frame/count)); 
    if(frame-lastCompare<minFrameToOneCompare) minFrameToOneCompare=int(frame-lastCompare); 
    lastCompare=frame;
    timeFind = int(toFPS*0.25);
    result = true;
  }
  frame++;
  return result;
}
void graph() // Рисование графика движения числа frame/count к количеству возможных положений (members^members)
{
  rect(width/2,0,width,height/2);
  stroke(100);
  line(width/2+1,height/4,width,height/4);
  stroke(255);
  
  text(0,width/2-10,height/2+5);
  text(""+mem2,width/2-55,height/4+5);
  
  stroke(0,255,0);
  int size = graphCount.size();
  
  graphWidthPoint = (size!=0?width/2/size:0);
  for(int i=0;i<size-1;i++) 
  {
    //double temp = (height/2)-graphHeightPoint*graphCount.get(i);
    //double temp2 = (height/2)-graphHeightPoint*graphCount.get(i+1);
    line(
      width/2 +graphWidthPoint*i,
      (float)((height/2)-graphHeightPoint*graphCount.get(i)),
      width/2 +graphWidthPoint*(i+1),
      (float)((height/2)-graphHeightPoint*graphCount.get(i+1))
    );
  }
  if(size !=0)
  text(
    graphCount.get(graphCount.size()-1),
    (float)(width/2-20+graphWidthPoint*(size-1)),
    (float)(20+height/2-graphHeightPoint*graphCount.get(size-1))
  );
}
void draw()
{
  
  
  background(0);
  if (frameCount % 10 == 0) fps=int(frameRate);
  
  
  noFill();
  stroke(255);
  graph();
  fill(255);
  noStroke();
  
  sinf.freq(map(mas[members-1], 0, 100, 200.0, 10000.0));
    println(map(mas[members-1], 0, 100, 200.0, 10000.0));
  
  if(flagPause)
  {
  //sinf.stop();
  }
  else
  {
    //sinf.play(200, 0.2);
    if(timeFind == 0)
    {
      for(int i=0;i<funcCount;i++) if(func()) break;
    }
    else
    {
      fill(0,255,0); 
      timeFind--;
    }
    
    //-----------------------STABEL FPS-------------------
  
    if(fps>toFPS && funcCount<1000000) 
    {
      if(fps-toFPS >25)funcCount+=8000;
      if(fps-toFPS >20)funcCount+=5000;
      if(fps-toFPS >15)funcCount+=2000;
      if(fps-toFPS >10)funcCount+=1000;
      if(fps-toFPS >2)funcCount+=100;
      else funcCount++;
    }
    if(fps<toFPS && funcCount>2) 
    {
      if(toFPS-fps >25)funcCount-=8000;
      if(toFPS-fps >20)funcCount-=5000;
      if(toFPS-fps >15)funcCount-=2000;
      if(toFPS-fps >10)funcCount-=1000;
      if(toFPS-fps >2)funcCount-=100;
      else funcCount--;
    }
    //-----------------------------------------------------
  }
  for(int i=0;i<members;i++) rect(i*(1+widthRect),height-heightRect*mas[i],widthRect,width/2);
  fill(255);
  text("FPS: "+fps+" PAUSE:"+flagPause,10,10);
  text("FUNC PER FRAME: "+funcCount,10,22);
  text("FRAMES: "+frame,10,34);
  text("TRUE COMPARE: "+count,10,46);
  text("FRAMES/TRUE COMPARE: "+(count==0?0:frame/count),10,58);
  text("MIN FRAME TO TRUE COMPARE: "+minFrameToOneCompare,10,70);
  text("GRAPH MEM^2: "+mem2,10,82);
  text("COM MAS: "+compareMas,10,94);
  text("MASIVE:",22,106); for(int i=0;i<members;i++) text(mas[i],81+i*10,106);
  //text("GRAPH WIDTH: "+graphWidthPoint,10,106);
  //text("GRAPH HEIGHT: "+graphHeightPoint,10,118);
}
