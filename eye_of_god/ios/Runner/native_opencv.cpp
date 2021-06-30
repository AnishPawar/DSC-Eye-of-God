#include <opencv2/opencv.hpp>
// #include "b64.h"
#include <vector>
#include <string>
#include <stdio.h>
#include <math.h>
using namespace cv;
using namespace std;

// Avoiding name mangling
extern "C"
{

    // Attributes to prevent 'unused' function from being removed and to make it visible
    __attribute__((visibility("default"))) __attribute__((used))
    const char *
    version()
    {
        return CV_VERSION;
    }

    __attribute__((visibility("default"))) __attribute__((used)) char *signalColor(int *inputImage, int *coorList, int *coorLen)
    {
        unsigned char uchararray[101376];
        for (int i = 0; i < 101376; i++)
            uchararray[i] = (unsigned char)inputImage[i];

        cv::Mat img = cv::Mat(352, 288, CV_8UC3, uchararray);

        cv::Rect crop_region1;
        crop_region1.x = coorList[0];
        crop_region1.y = coorList[1];
        crop_region1.width = coorList[2];
        crop_region1.height = coorList[3];
        img = img(crop_region1);

        int h_bins = 256, s_bins = 256;
        int histSize[] = {h_bins, s_bins};
        float h_ranges[] = {0, 256};
        float s_ranges[] = {0, 256};
        const float *ranges[] = {h_ranges, s_ranges};
        int channels[] = {1, 2};
        Mat hist_base, hist_half_down, hist_test1, hist_test2;
        calcHist(&img, 1, channels, Mat(), hist_base, 2, histSize, ranges, true, false);

        // int ww = 256;
        // int hh = 256;
        // int ww13 = static_cast<int>(ww / 3);
        // int ww23 = 2 * ww13;
        // int hh13 = static_cast<int>(hh / 3);
        // int hh23 = 2 * hh13;
        // cv::Mat mask_r = cv::Mat::zeros(cv::Size(hist_base.size().width, hist_base.size().height), CV_8UC1);
        // cv::Mat mask_g = cv::Mat::zeros(cv::Size(hist_base.size().width, hist_base.size().height), CV_8UC1);

        // vector<Point> ptur;
        // ptur.push_back(Point(ww13, 0));
        // ptur.push_back(Point(ww - 1, hh23));
        // ptur.push_back(Point(ww - 1, 0));
        // vector<Point> pt;
        // approxPolyDP(ptur, pt, 1.0, true);
        // fillConvexPoly(mask_r, &pt[0], pt.size(), {255, 255, 255}, 8, 0);

        // vector<Point> ptbl;
        // ptbl.push_back(Point(0, hh13));
        // ptbl.push_back(Point(ww23, hh - 1));
        // ptbl.push_back(Point(0, hh - 1));
        // vector<Point> pt1;
        // approxPolyDP(ptbl, pt1, 1.0, true);
        // fillConvexPoly(mask_g, &pt1[0], pt1.size(), {255, 255, 255}, 8, 0);

        // Mat region_g;
        // cout << hist_base.size() << endl;
        // cout << mask_r.size() << endl;

        // Mat res_r = hist_base.clone();
        // res_r.setTo(Scalar(0), ~mask_r);

        // Mat res_g = hist_base.clone();
        // res_g.setTo(Scalar(0), ~mask_g);

        // int count_r = 0;
        // for (int i = 0; i < 256; i++)
        // {
        //     for (int j = 0; j < 256; j++)
        //     {
        //         if (res_r.at<cv::Vec3b>(i, j)[0] > 0)
        //         {
        //             count_r++;
        //         }
        //     }
        // }

        // int count_g = 0;
        // for (int i = 0; i < 256; i++)
        // {
        //     for (int j = 0; j < 256; j++)
        //     {
        //         if (res_g.at<cv::Vec3b>(i, j)[0] > 0)
        //         {
        //             count_g++;
        //         }
        //     }
        // }

        // int Threshold = 100;
        char *color;
        // if (count_r > count_g and count_r > Threshold)
        //     color = "red";
        // else if (count_g > count_r and count_g > Threshold)
        //     color = "green";
        // else if (count_r < Threshold and count_g < Threshold)
        //     color = "yellow";
        // else
        //     color = "other";
        color = "OK";
        return color;
    }

    __attribute__((visibility("default"))) __attribute__((used)) char *cvProcess(int *inputImage, int *coorList, int *Labels, int *coorLen)
    {

        unsigned char uchararray[65536];
        for (int i = 0; i < 65536; i++)
            uchararray[i] = (unsigned char)inputImage[i];

        cv::Mat image = cv::Mat(256, 256, CV_8UC1, uchararray);

        //int counter = sizeof(coorList) / sizeof(coorList[0]) / 4;
        // int counter = sizeof(coorList) / sizeof(coorList[0]) / 4;
        //if()
        int counter = coorLen[0] / 4;
        // int counter = 1;
        std::vector<int> finalStorageLabels;
        std::vector<int> finalStorageQuad;
        std::vector<int> finalStorageInten;

        std::vector<int> tempStorageQuad;
        std::vector<int> tempStorageInten;
        std::vector<int> tempStorageLabels;
        int test_this = 104;

        for (int i = 0; i < counter; i++)
        {
            test_this = 10;
            int CurrentClass;
            int singleBox[4];
            for (int j = i * 4; j < (i * 4) + 4; j++)
            {
                if (coorList[j] < 0)
                {
                    coorList[j] = 0;
                }
                singleBox[j - (4 * i)] = coorList[j];
            }
            CurrentClass = Labels[i];

            int *arr1 = new int[2];
            //            Starting Is Close
            int x = singleBox[0];
            int y = singleBox[1];
            int w = singleBox[2];
            int h = singleBox[3];
            int motorNo = 0;
            int width = image.size().width;
            int height = image.size().height;

            if ((0 < (x + (w / 2))) && ((x + (w / 2)) < (width / 4)))
            {
                motorNo = 1;
            }
            else if (((width / 4) < (x + (w / 2))) && ((x + (w / 2)) < (2 * (width / 4))))
            {
                motorNo = 2;
            }
            else if (((2 * (width / 4)) < (x + (w / 2))) && ((x + (w / 2)) < (3 * (width / 4))))
            {
                motorNo = 3;
            }
            else if (((3 * (width / 4)) < (x + (w / 2))) && ((x + (w / 2)) < (width)))
            {
                motorNo = 4;
            }

            if (0 <= x && 0 <= w && x + w <= 255 && 0 <= y && 0 <= h && y + h <= 255)
            {
                cv::Rect crop_region1;
                crop_region1.x = x;
                crop_region1.y = y;
                crop_region1.width = w;
                crop_region1.height = h;
                Mat roi = image(crop_region1);
                // imshow("ok", roi);
                // waitKey(0);

                Scalar temp_mean = mean(roi);
                int initThresh = temp_mean[0];
                arr1[0] = motorNo;
                cout << initThresh;
                if (initThresh > 30 )
                {
                    float mappedOuptput = sqrt((initThresh) / 0.0006) + 270;

                    arr1[1] = static_cast<int>(mappedOuptput) + 100;
                    test_this = 30;
                }
                else
                {
                    arr1[1] = 0;
                    test_this = 40;
                }

                //            Ending Is Close
                tempStorageQuad.push_back(arr1[0]);
                tempStorageInten.push_back(arr1[1]);
                tempStorageLabels.push_back(CurrentClass);
            }
            else
            {
                continue;
            }
        }

        // cout << "It is:" << sizeof(tempStorageQuad) / sizeof(tempStorageQuad[0]) / 2 << endl;
        bool flag;
        for (int quad = 1; quad <= 4; quad++)
        {
            flag = true;
            std::vector<int> tempList;
            int maxIntensity = 0;
            int tempLabel = 0;
            for (int i = 0; i < tempStorageQuad.size(); i++)
            {
                if (tempStorageQuad[i] == quad)
                {
                    flag = false;
                    if (tempStorageInten[i] > maxIntensity)
                    {
                        maxIntensity = tempStorageInten[i];
                        tempLabel = tempStorageLabels[i];
                    }
                }
            }
            if (flag)
            {
                int noObjIntensity;

                int width = image.size().width;
                int height = image.size().height;
                cv::Rect crop_region;
                crop_region.x = (static_cast<int>(width / 4) * (quad - 1));
                crop_region.y = 0;
                crop_region.width = (static_cast<int>(width / 4)) - 1;
                crop_region.height = height;
                Mat region_wise = image(crop_region);

                Scalar temp_mean = mean(region_wise);
                int initThresh = temp_mean[0];

                if (initThresh >= 30)
                {
                    float mappedOuptput = sqrt((initThresh) / 0.0006) + 270;
//                    float mappedOuptput = (0.001*initThresh*initThresh) + 250;
                    noObjIntensity = static_cast<int>(mappedOuptput + 100);
                }
                else
                {
                    noObjIntensity = 0;
                }

                finalStorageLabels.push_back(tempLabel);
                finalStorageInten.push_back(noObjIntensity);
                finalStorageQuad.push_back(quad);
            }
            else
            {
                finalStorageLabels.push_back(tempLabel);
                finalStorageInten.push_back(maxIntensity);
                finalStorageQuad.push_back(quad);
            }
        }

        //    "100:28;""
        // "100:10;100:20;100:Bike";
        char opString[28] = "";
        for (int i = 0; i < 4; i++)
        {

            //        int x = -42;
            int x2 = finalStorageInten[i];
            int length = snprintf(NULL, 0, "%d", x2);
            char *str1 = (char *)(malloc(length + 1));
            snprintf(str1, length + 1, "%d", x2);

            int x1 = finalStorageLabels[i];
            // int x1 = coorLen[0];
            int length1 = snprintf(NULL, 0, "%d", x2);
            char *str2 = (char *)(malloc(length1 + 1));
            snprintf(str2, length1 + 1, "%d", x1);

            strcat(opString, str1);
            strcat(opString, ":");
            strcat(opString, str2);
            strcat(opString, ";");
            free(str1);
            free(str2);
        }

        // cout << opString;

        return opString;
    }
}
