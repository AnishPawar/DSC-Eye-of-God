#include "opencv2/imgcodecs.hpp"
#include "opencv2/highgui.hpp"
#include "opencv2/imgproc.hpp"
#include "opencv2/core.hpp"
#include <iostream>
using namespace std;
using namespace cv;



int main(int argc, char** argv)
{
    Mat img = imread("/Users/anishpawar/Desktop/Screenshot 2021-06-17 at 11.41.46 PM.png");

    if (img.empty())
    {
        cout << "Could not open or find the images!\n" << endl;
        return -1;
    }

    int h_bins = 256, s_bins = 256;
    int histSize[] = { h_bins, s_bins };
    float h_ranges[] = { 0, 256 };
    float s_ranges[] = { 0, 256 };
    const float* ranges[] = { h_ranges, s_ranges };
    int channels[] = { 1, 2 };
    Mat hist_base, hist_half_down, hist_test1, hist_test2;
    calcHist(&img, 1, channels, Mat(), hist_base, 2, histSize, ranges, true, false);

    int ww = 256;
    int hh = 256;
    int ww13 = static_cast<int>(ww / 3);
    int ww23 = 2 * ww13;
    int hh13 = static_cast<int>(hh / 3);
    int hh23 = 2 * hh13;
    cv::Mat mask_r = cv::Mat::zeros(cv::Size(hist_base.size().width, hist_base.size().height), CV_8UC1);
    cv::Mat mask_g = cv::Mat::zeros(cv::Size(hist_base.size().width, hist_base.size().height), CV_8UC1);

    vector<Point> ptur;
       ptur.push_back(Point(ww13, 0));
       ptur.push_back(Point(ww - 1, hh23));
       ptur.push_back(Point(ww - 1, 0));
       vector<Point> pt;
       approxPolyDP(ptur, pt, 1.0, true);
       fillConvexPoly(mask_r, &pt[0], pt.size(), {255, 255, 255}, 8, 0);

    vector<Point> ptbl;
    ptbl.push_back(Point(0, hh13));
    ptbl.push_back(Point(ww23 , hh-1));
    ptbl.push_back(Point(0, hh-1));
    vector<Point> pt1;
    approxPolyDP(ptbl, pt1, 1.0, true);
    fillConvexPoly(mask_g, &pt1[0], pt1.size(), {255, 255, 255}, 8, 0);
    

    Mat region_g;
    cout<<hist_base.size()<<endl;
    cout<<mask_r.size()<<endl;
    
    Mat res_r = hist_base.clone();
    res_r.setTo(Scalar(0), ~mask_r);
    
    Mat res_g = hist_base.clone();
    res_g.setTo(Scalar(0), ~mask_g);
    
    int count_r=0;
    for (int i=0; i<256; i++) {
        for (int j=0; j<256; j++) {
            if (res_r.at<cv::Vec3b>(i,j)[0]>0) {
                count_r++;
            }
            
        }
    }
    
    
    int count_g=0;
    for (int i=0; i<256; i++) {
        for (int j=0; j<256; j++) {
            if (res_g.at<cv::Vec3b>(i,j)[0]>0) {
                count_g++;
            }
            
        }
    }
    cout<<"R is:"<<count_r<<endl;
    cout<<"G is:"<<count_g<<endl;
    
    
    int Threshold=100;
    char *color;
    if (count_r > count_g and count_r > Threshold)
        color = "red";
    else if (count_g > count_r and count_g > Threshold)
        color = "green";
    else if (count_r < Threshold and count_g < Threshold)
        color = "yellow";
    else
        color = "other";
    
    cout<<"Signal Color:"<<color<<endl;
    

    cv::imshow("mask", img);
    cv::waitKey(0);

    return 0;
}
