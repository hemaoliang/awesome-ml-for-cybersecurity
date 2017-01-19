require 'nn'

x = torch.rand(8,50, 200)

backend = nn

function ConvBNReLU(nInputPlane, nOutputPlane)
      vgg:add(backend.SpatialConvolution(nInputPlane, nOutputPlane, 3,3, 1,1, 1,1))
      vgg:add(nn.SpatialBatchNormalization(nOutputPlane,1e-3))
      vgg:add(backend.ReLU(true))
      return vgg
end

MaxPooling = backend.SpatialMaxPooling

vgg = nn.Sequential()
vgg:add(nn.Reshape(1,50,200))

ConvBNReLU(1,64)
ConvBNReLU(64,64)
vgg:add(MaxPooling(2,2,2,2):ceil())

ConvBNReLU(64,128)
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

ConvBNReLU(512,512)--:add(nn.Dropout(0.4,nil,true))
ConvBNReLU(512,512)--:add(nn.Dropout(0.4,nil,true))
ConvBNReLU(512,512)
vgg:add(MaxPooling(2,2,2,2):ceil())
vgg:add(nn.View(512*2*7))

print(vgg)

print(#vgg:forward(x))
