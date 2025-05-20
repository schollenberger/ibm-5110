// Test out CPP features

//#include <conio.h>
#include <stdio.h>
#include <iostream.h>
#include <istring.hpp>


int main(int argc, char **argv)
  {
  cout << "Hello World" << endl;
  IString is_txt = "Integer value ";
  int num = 23;
  IString is_num = num;
  is_num = num + 20;
    
  cout << is_txt + is_num << endl;
  return 0;
  }
  