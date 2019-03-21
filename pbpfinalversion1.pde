import KinectPV2.*;

KinectPV2 kinect;
int index=0;
float d1;
int count=0;
int timecount=0;
float prex, prey;
float angle;
boolean triger=false;
PImage img;
float t=0;
float n=0.05;
float m=1;
float rectsize=2;
int caseIndex;
float p=0;
boolean tracked=false;
void setup() {
  size (800, 855, P3D);
  img=loadImage("pbpfinal.JPG");
  kinect = new KinectPV2(this);

  //enable HD Face detection
  kinect.enableHDFaceDetection(true);
  kinect.enableColorImg(true); //to draw the color image
  kinect.init();
}

void draw() {
  //float n=map(angle,0,30,0.05,0.3);

  t+=n;
  //n+=p;
  n=constrain(n, 0.01, 0.5);
  
  //size+=m;
  rectsize=constrain(rectsize, 0, 50);


  background(0);
  image(img, 0, 0);
  
  loadPixels();

  //
  ArrayList<HDFaceData> hdFaceData = kinect.getHDFaceVertex();

  for (int j = 0; j < hdFaceData.size(); j++) {
    //obtain a the HDFace object with all the vertex data
    HDFaceData HDfaceData = (HDFaceData)hdFaceData.get(j);
    //translate(0,0,200);

    if (HDfaceData.isTracked()) {
      tracked=true;

      if (count<200) {
        count++;
        fill(255, 255, 0);
        prex=HDfaceData.getX(150);
        prey=HDfaceData.getY(150);
      } else {
        //draw the vertex points
        fill(0, 255, 0);
      }
      pushMatrix();
     translate(0, 0, 200);
      beginShape(POINTS);
      for (int i = 0; i < KinectPV2.HDFaceVertexCount; i++) {
        float x = HDfaceData.getX(i);
        float y = HDfaceData.getY(i);
        vertex(x, y);
      }
      endShape();

      d1=dist(prex, prey, 0, HDfaceData.getX(150), HDfaceData.getY(150), 200);
      popMatrix();



      angle=degrees(acos(200/d1));
      if (angle>20) {
        triger=true;
        caseIndex=0;
      } else {
        triger=false;
        caseIndex=1;
      }
    } else {
      triger=false;
      tracked=false;
      caseIndex=2;
      fill(255, 0, 0);
    }
    //print(triger);
    print(tracked);
   // print(caseIndex);
    println(rectsize);
    ellipse(width-10, 10, 5, 5);
  }
  //
 
  switch(caseIndex) {
  case 0:
    //p+=0.01;
    //m=1;
    n+=0.01;
    rectsize+=0.7;
    break;
  case 1:
    //p-=0.01;
    //m=-1;
    n-=0.001;
    rectsize-=0.05;
    break;
  case 2:
    //p+=0.005;
    //m=0.5;
    n+=0.0005;
    rectsize+=0.05;
    break;
  }
  //fill(255,255,255,5);                              // fade to white by drawing trancelusent white rect above
  //  rect(0,0, width, height);
   int edgeAmount=2;
  for (int x=edgeAmount; x<width-edgeAmount; x+=3) {
    for (int y=edgeAmount; y< height-edgeAmount; y+=3) {
      PxPGetPixel(x, y, pixels, width);
      int thisR=R;
      int thisG=G;
      int thisB=B;
      float colorDifference=0;
      for (int blurX=x- edgeAmount; blurX<=x+ edgeAmount; blurX++) {
        for (int blurY=y- edgeAmount; blurY<=y+ edgeAmount; blurY++) {
          PxPGetPixel(blurX, blurY, pixels, width);     // get the RGB of our pixel and place in RGB globals
          colorDifference+=dist(R, G, B, thisR, thisG, thisB);
        }
      }

      float threshold = height*3.5/4;                 
      if ( colorDifference> threshold ) {                           // if our pixel is an edge then draw a rect

        fill(thisR, thisG, thisB);
        noStroke();
        randomSeed(2);
        rect(x, y, rectsize*noise(t+50), rectsize*noise(2*t+50));
      }
    }
  }
  image(kinect.getColorImage(), 0, 0,200,200);
}

int R, G, B, A; // you must have these global varables to use the PxPGetPixel()
void PxPGetPixel(int x, int y, int[] pixelArray, int pixelsWidth) {
  int thisPixel=pixelArray[x+y*pixelsWidth];     // getting the colors as an int from the pixels[]
  A = (thisPixel >> 24) & 0xFF;                  // we need to shift and mask to get each component alone
  R = (thisPixel >> 16) & 0xFF;                  // this is faster than calling red(), green() , blue()
  G = (thisPixel >> 8) & 0xFF;   
  B = thisPixel & 0xFF;
}

void PxPSetPixel(int x, int y, int r, int g, int b, int a, int[] pixelArray, int pixelsWidth) {
  a =(a << 24);                       
  r = r << 16;                       // We are packing all 4 composents into one int
  g = g << 8;                        // so we need to shift them to their places
  color argb = a | r | g | b;        // binary "or" operation adds them all into one int
  pixelArray[x+y*pixelsWidth]= argb;    // finaly we set the int with te colors into the pixels[]
}
