require 'nn';
--require 'cunn';
require 'MultiCrossEntropyCriterion'

local models = {}
function models.cnnModel(k,c)
    local k = k or 5
    local c = c or 36
-- Will use "ceil" MaxPooling because we want to save as much
-- space as we can
    local vgg = nn.Sequential()
    vgg:add(nn.Reshape(1,50,200))

    local backend_name = 'nn'

    local backend
    if backend_name == 'cudnn' then
      require 'cudnn'
      backend = cudnn
    else
      backend = nn
    end
    local MaxPooling = backend.SpatialMaxPooling

    -- building block
    local function ConvBNReLU(nInputPlane, nOutputPlane)
      vgg:add(backend.SpatialConvolution(nInputPlane, nOutputPlane, 3,3, 1,1, 1,1))
      vgg:add(nn.SpatialBatchNormalization(nOutputPlane,1e-3))
      vgg:add(backend.ReLU(true))
      return vgg
    end
    ConvBNReLU(1,64)--:add(nn.Dropout(0.3,nil,true))
    ConvBNReLU(64,64)
    vgg:add(MaxPooling(2,2,2,2):ceil())

    ConvBNReLU(64,128)--:add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(128,128)
    vgg:add(MaxPooling(2,2,2,2):ceil())

    ConvBNReLU(128,256)--:add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(256,256)--:add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(256,256)
    vgg:add(MaxPooling(2,2,2,2):ceil())

    ConvBNReLU(256,512)--:add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(512,512)--:add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(512,512)
    vgg:add(MaxPooling(2,2,2,2):ceil())

    -- In the last block of convolutions the inputs are smaller than
    -- the kernels and cudnn doesn't handle that, have to use cunn
    backend = nn
    ConvBNReLU(512,512)--:add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(512,512)--:add(nn.Dropout(0.4,nil,true))
    ConvBNReLU(512,512)
    vgg:add(MaxPooling(2,2,2,2):ceil())
    vgg:add(nn.View(512*2*7))

    classifier = nn.Sequential()
    --classifier:add(nn.Dropout(0.5,nil,true))
    classifier:add(nn.Linear(512*2*7,512))
    classifier:add(nn.BatchNormalization(512))
    classifier:add(nn.ReLU(true))
    --classifier:add(nn.Dropout(0.5,nil,true))
    classifier:add(nn.Linear(512,k*c))
    vgg:add(classifier)
    vgg:add(nn.Reshape(k,c))
    return vgg,nn.MultiCrossEntropyCriterion()
end


-- vgg model is too large and will cause out of memory in cpu mode
-- here is a much simple cnn model based lenet

function models.lenetModel(k,c)
    local k = k or 5
    local c = c or 36
    
    model = nn.Sequential()
    model:add(nn.Reshape(1, 50, 200))

    model:add(nn.SpatialConvolutionMM(1, 20, 3, 3, 1, 1, 1, 1))
    model:add(nn.SpatialBatchNormalization(20,1e-3))
    model:add(nn.ReLU(true))
    model:add(nn.SpatialMaxPooling(2, 2 , 2, 2, 0, 0))

    model:add(nn.SpatialConvolutionMM(20, 50, 3, 3, 1, 1, 1, 1))
    model:add(nn.SpatialBatchNormalization(50,1e-3))
    model:add(nn.ReLU(true))
    model:add(nn.SpatialMaxPooling(2, 2 , 2, 2, 0, 0))

    model:add(nn.SpatialConvolutionMM(50, 50, 3, 3, 1, 1, 1, 1))
    model:add(nn.SpatialBatchNormalization(50,1e-3))
    model:add(nn.ReLU(true))
    model:add(nn.SpatialMaxPooling(2, 2 , 2, 2, 0, 0))

    model:add(nn.View(50*6*25))

    classifier = nn.Sequential()
    --classifier:add(nn.Dropout(0.5,nil,true))
    classifier:add(nn.Linear(50*6*25,512))
    classifier:add(nn.BatchNormalization(512))
    classifier:add(nn.ReLU(true))
    --classifier:add(nn.Dropout(0.5,nil,true))
    classifier:add(nn.Linear(512,k*c))
    model:add(classifier)
    model:add(nn.Reshape(k,c))

    model = require('weight-init')(model, 'xavier')

    return model,nn.MultiCrossEntropyCriterion()	

end

return models
