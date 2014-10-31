#include <cstdlib>
#include <iostream>
#include <string>
#include <SLIC.h>
#include <opencv2/opencv.hpp>

std::string parent_name(const std::string & path)
{
  size_t index = path.find_last_of("/\\");
  
  if (index == path.length() - 1)
  {
    index = path.find_last_of("/\\", path.length() - 2);
    if (index == path.npos)
    {
      return "";
    }
    else
    {
      return path.substr(0, index + 1);
    }
  }
  else
  {
    if (index == path.npos)
    {
      return "";
    }
    else
    {
      return path.substr(0, index + 1);
    }
  }
}

int main(int argc, char ** argv)
{
  if (argc != 3)
  {
    std::cerr << "ERROR: expected 2 argumens: <input_image_path> <num_superpixels>" << std::endl;
    return EXIT_FAILURE;
  }

  std::string input_image_path = argv[1];
  int num_superpixels = atoi(argv[2]);

  cv::Mat image_rgb = cv::imread(input_image_path);
  cv::Mat image_uint(image_rgb.rows, image_rgb.cols, CV_32SC1);

  for (int row = 0; row < image_rgb.rows; ++row)
  {
    for (int col = 0; col < image_rgb.cols; ++col)
    {
      cv::Vec3b pixel = image_rgb.at<cv::Vec3b>(row, col);
      int b = pixel[0];
      int g = pixel[1];
      int r = pixel[2];

      int pixel_int = b + (g << 8) + (r << 16);
      image_uint.at<int>(row, col) = pixel_int;
    }
  }

  SLIC slic;
  int * labels = new int[image_uint.cols * image_uint.rows];
  int num_labels = 0;

  slic.PerformSLICO_ForGivenK(
    image_uint.ptr<unsigned int>(0),
    image_uint.cols,
    image_uint.rows,
    labels,
    num_labels,
    num_superpixels,
    10.0);
  slic.SaveSuperpixelLabels(labels,
    image_uint.cols,
    image_uint.rows,
    input_image_path,
    parent_name(input_image_path));

  return EXIT_SUCCESS;
}
