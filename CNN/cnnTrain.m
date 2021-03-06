function [W, b] = cnnTrain(cnn, W, b, Z, Y)
%%CNNTRAIN 
%   
%   Copyright (C) 2014 by Xiangzeng Zhou
%   Author: Xiangzeng Zhou <xenuts@gmail.com>
%   Created: 20 Sep 2014

%   Time-stamp: <2014-10-08 10:37:42 by xenuts>

    %% Learning Settings
    Ln.mom = 0.95;
    Ln.velocity = [];
    Ln.alpha = cnn.Opts.Alpha;
    Ln.momInc = 20;
    %% Main Loop
    opts = cnn.Opts;
    num_batches = opts.NumBatches;
    iter = 0;
    for i = 1 : opts.NumEpoch
        fprintf(['Epoch ', num2str(i), '/', num2str(opts.NumEpoch), '\n']);
        if opts.RandomShuffle
            batch_idx = randperm(opts.NumCases);
        else
            batch_idx = 1 : opts.NumCases;
        end
        tE = tic;
        
        for j = 1 : num_batches
            %% Updating Momentum
            iter = iter + 1;
            if (iter == Ln.momInc)
                Ln.mom = cnn.Opts.Momentum; 
            end
            tB = tic;
            %% Select batch
            Y_batch = Y(batch_idx((j-1)*opts.BatchSize+1 : j*opts.BatchSize), :);
            for L = 1 : numel(cnn.Layers) %Z{1} is input, Z{2:end}=[]
                if(L==1)
                    Z_batch{L} = Z{L}(:, :, :, batch_idx((j-1)*opts.BatchSize+1 : j*opts.BatchSize));
                else
                    Z_batch{L} = [];
                end                
            end
            
            %% Get Cost and Gradient via ff and bp   
            [Cost, Grad] = cnnCost(cnn, W, b, Z_batch, Y_batch);
            
            %% If Check Gradient
            if(cnn.Opts.CHECK_GRAD && i == 2) % Gradient Check
                cnnCheckGrad(cnn, W, b, Z_batch, Y_batch, Grad);                                
                cnn.Opts.CHECK_GRAD = 0; % Take only one time because it's too time-comsuming
            end
            
            %% Learn Learnable Parameters
            [W, b, Ln] = cnnLearn(cnn, W, b, Grad, Ln);

            tB = toc(tB);
% % %             fprintf('    Cost on Batch %4d/%-4d is %3.3f => Time: %.3f s\n', j, num_batches, Cost, tB);
        end
        tE = toc(tE);
        
        %% Show Prediction on Training sets
        PREDICT = 1;
        Z0 = cnnFF(cnn, W, b, Z, PREDICT);
        probs = Z0{end};
        [~, preds] = max(probs,[],1);
        fprintf('Iter %d => Accuracy: %.3f\n', i, sum( preds' == Y) / opts.NumCases);
        
        %% Updating Learning Rate Alpha
        Ln.alpha = Ln.alpha / 1.5; % Aneal Learning Rate by factor of 2 each epoch
        disp(Ln.alpha);
        if(Ln.alpha < cnn.Opts.MinAlpha)
            Ln.alpha = cnn.Opts.MinAlpha;
        end
    end
end