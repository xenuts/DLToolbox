function [] = test_cnn()
%%TEST_CNN 
%   
%   Copyright (C) 2014 by Xiangzeng Zhou
%   Author: Xiangzeng Zhou <xenuts@gmail.com>
%   Created: 19 Sep 2014

%   Time-stamp: <2014-10-06 08:21:07 by xenuts>

    warning('off');

    [cnn, W, b, Z] = cnnSetup();
    
    [X, Y] = LoadData();
    
    [cnn, W, b, Z] = cnnInit(cnn, X, W, b, Z);
    clear X;
    
%    CNNSummary(cnn); % !!TODO
    
    RandStream.setGlobalStream(RandStream('mt19937ar','seed', 1));
    cnn = cnnTrain(cnn, W, b, Z, Y);
