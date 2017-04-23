#include <iostream>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <GL/glut.h>
using namespace std;

double MinRe = -2.0;
double MaxRe = 1.0;
double MinIm = -1.2;

__global__ void mandelbrotKernel(double MaxIm, double Im_factor,double Re_factor,unsigned MaxIterations) {
	int y = threadIdx.x + blockIdx.x*blockDim.x;
	int x = threadIdx.y + blockIdx.y*blockDim.y;
	double c_im = MaxIm - y*Im_factor;
	double c_re = MinRe + x*Re_factor;

	double Z_re = c_re, Z_im = c_im;
	bool isInside = true;
	for (unsigned n = 0; n<MaxIterations; ++n)
	{
		double Z_re2 = Z_re*Z_re, Z_im2 = Z_im*Z_im;
		if (Z_re2 + Z_im2 > 4)
		{
			isInside = false;
			break;
		}
		Z_im = 2 * Z_re*Z_im + c_im;
		Z_re = Z_re2 - Z_im2 + c_re;
	}
	if (isInside)
	{
		glBegin(GL_POINTS);
			glColor3f(0, 0, 0);
			glVertex2i(x, y);
		glEnd();
	}

}

void drawMandelbrot()
{
	unsigned ImageHeight = glutGet(GLUT_WINDOW_HEIGHT);
	unsigned ImageWidth = glutGet(GLUT_WINDOW_WIDTH);
	double MaxIm = MinIm + (MaxRe - MinRe)*ImageHeight / ImageWidth;
	double Re_factor = (MaxRe - MinRe) / (ImageWidth - 1);
	double Im_factor = (MaxIm - MinIm) / (ImageHeight - 1);
	unsigned MaxIterations = 30;

	//glBegin(GL_POINTS);
	
	dim3 dimBlock(32, 32);
	unsigned blockRows = (ImageHeight % 32 ? ImageHeight / 32 : ImageHeight / 32 + 1);
	unsigned blockCols = (ImageWidth % 32 ? ImageWidth / 32 : ImageWidth / 32 + 1);
	dim3 dimGrid(blockRows, blockCols);
	mandelbrotKernel <<<dimGrid,dimBlock>>>(MaxIm,Im_factor,Re_factor,MaxIterations);
	
	//glEnd();
}

void display()
{
	glClear(GL_COLOR_BUFFER_BIT);

	drawMandelbrot();
	glFlush();
}

void init()
{
	glClearColor(1, 1, 1, 1);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluOrtho2D(0, glutGet(GLUT_WINDOW_WIDTH), 0, glutGet(GLUT_WINDOW_HEIGHT));
}

int main(int argc, char** argv)
{
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB);
	glutInitWindowPosition(50, 50);
	glutInitWindowSize(600, 600);
	glutCreateWindow("Mandelbrot Set");

	init();
	glutDisplayFunc(display);
	glutMainLoop();
	return 0;
}
