local dir = '/home/tracyhe/data_download/simplecaptcha_generate/'
local validationSize = 1000
local iterations = 30
local batchSize = 32
local sgd_config = {
      learningRate = 0.1,
      learningRateDecay = 5.0e-6,
      momentum = 0.9
   }

--local sgd_config = {
--      learningRate = 0.1,
--      learningRateDecay = 1.0e-4,
--      momentum = 0.9
--   }

local data = require 'data';
--第一次运行需要执行storeXY(dir)
--data.storeXY(dir)
--local X,Y = data.loadXY(dir)

print('loading data begin..')

local Y = data.loadY(dir)
local X = data.loadX(dir,Y:size(1),50,200)
local Xt,Yt,Xv,Yv = data.split(X,Y,validationSize)

print('loading data end..')

local models = require 'models';
--local net,ct = models.cnnModel()
local net,ct = models.lenetModel()

print(net)

print('begin training..')

--local net = net:cuda()
--local ct = ct:cuda()
--local Xv = Xv:cuda()
--local Yv = Yv:cuda()
--local Xt = Xt:cuda()
--local Yt = Yt:cuda()

local train = require 'train';

train.sgd(net,ct,Xt,Yt,Xv,Yv,iterations,sgd_config,batchSize)

--torch.save(dir .. 'net.t7',net)

--print('valid .. '.. train.accuracy(Xv,Yv,net,batchSize))
--print('valid .. '.. train.accuracyK(Xv,Yv,net,batchSize))
