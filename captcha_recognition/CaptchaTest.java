import java.io.File;
import java.io.IOException; 
 
import java.awt.Color;  
import java.awt.Font;  
import java.util.ArrayList;  
import java.util.List;  

import nl.captcha.Captcha;  
import nl.captcha.Captcha.Builder;  
import nl.captcha.backgrounds.GradiatedBackgroundProducer;  
import nl.captcha.gimpy.DropShadowGimpyRenderer;  
import nl.captcha.noise.CurvedLineNoiseProducer;  
import nl.captcha.noise.NoiseProducer;  
import nl.captcha.servlet.CaptchaServletUtil;  
import nl.captcha.text.producer.DefaultTextProducer;  
import nl.captcha.text.renderer.DefaultWordRenderer; 
import nl.captcha.text.renderer.ColoredEdgesWordRenderer; 
import nl.captcha.text.renderer.WordRenderer;  
import nl.captcha.gimpy.FishEyeGimpyRenderer;
import nl.captcha.gimpy.DropShadowGimpyRenderer;
import nl.captcha.gimpy.RippleGimpyRenderer;
import nl.captcha.gimpy.BlockGimpyRenderer;

import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;

public class CaptchaTest{
    //@Value("${_width}")  
    private int _width = 200;  
    //@Value("${_height}")  
    private int _height = 50;  
    //@Value("${_noise}")  
    private int _noise = 1;  
    //@Value("${_text}")  
    private String _text = null;  
    //private String _text = "number:2,word:3";
    //@Value("${chinese_text}")  
    private String base; 
    private int _pngcnt = 1;

public void showCaptcha() {  
        Builder builder = new Captcha.Builder(_width, _height);  
        // 增加边框  
        builder.addBorder();  
        NoiseProducer nProd = new CurvedLineNoiseProducer(Color.BLACK, 2);  
        // 是否增加干扰线条  
        if (_noise == 1)  
            builder.addNoise(nProd);  
        // ----------------自定义字体大小-----------  
        // 自定义设置字体颜色和大小 最简单的效果 多种字体随机显示  
        List<Font> fontList = new ArrayList<Font>();  
        fontList.add(new Font("宋体", Font.HANGING_BASELINE, 40));// 可以设置斜体之类的  
        fontList.add(new Font("Courier", Font.ITALIC, 40));  
        fontList.add(new Font("宋体", Font.PLAIN, 40));  
  
        // 加入多种颜色后会随机显示 字体空心  
        List<Color> colorList = new ArrayList<Color>();  
        //colorList.add(Color.green);  
        colorList.add(Color.pink);  
        //colorList.add(Color.gray);  
        //colorList.add(Color.blue);  
    DefaultWordRenderer cwr = new DefaultWordRenderer(colorList, fontList);  
        //ColoredEdgesWordRenderer cwr= new ColoredEdgesWordRenderer(colorList,fontList);  
        WordRenderer wr = cwr;  
        // 增加文本，默认为5个随机字符.  
        if (_text == null) {  
            builder.addText();  
        } else {  
            String[] ts = _text.split(",");  
            for (int i = 0; i < ts.length; i++) {  
                String[] ts1 = ts[i].split(":");  
                if ("chinese".equals(ts1[0])) {  
                    char[] chinese = base.toCharArray();  
                    builder.addText(  
                            new DefaultTextProducer(Integer.parseInt(ts1[1]),  
                                    chinese), wr);  
                } else if ("number".equals(ts1[0])) {  
                    char[] numberChar = new char[] { '0', '1', '2', '3', '4',  
                            '5', '6', '7', '8', '9' };  
                    builder.addText(  
                            new DefaultTextProducer(Integer.parseInt(ts1[1]),  
                                    numberChar), wr);  
                } else if ("word".equals(ts1[0])) {  
                    char[] numberChar = new char[] { 'A', 'B', 'C', 'D', 'E',  
                            'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',  
                            'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y',  
                            'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i',  
                            'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',  
                            't', 'u', 'v', 'w', 'x', 'y', 'z' };  
                    builder.addText(  
                            new DefaultTextProducer(Integer.parseInt(ts1[1]),  
                                    numberChar), wr);  
                } else {  
                    builder.addText(  
                            new DefaultTextProducer(Integer.parseInt(ts1[1]),  
                                    null), wr);  
                }  
            }  
        }// --------------添加背景-------------  
            // 设置背景渐进效果 以及颜色 form为开始颜色，to为结束颜色  
        GradiatedBackgroundProducer gbp = new GradiatedBackgroundProducer();  
        gbp.setFromColor(Color.GRAY);  
        gbp.setToColor(Color.WHITE);  
  
        // 无渐进效果，只是填充背景颜色  
//      FlatColorBackgroundProducer fbp=new FlatColorBackgroundProducer(Color.white);  
        // 加入网纹--一般不会用  
//       SquigglesBackgroundProducer sbp=new SquigglesBackgroundProducer();  
        // 没发现有什么用,可能就是默认的  
        // TransparentBackgroundProducer tbp = new  
        // TransparentBackgroundProducer();  
  
        builder.addBackground(gbp);  
  
        // ---------装饰字体---------------  
        // 字体边框齿轮效果 默认是3  
      builder.gimp(new BlockGimpyRenderer(1));  
        // 波纹渲染 相当于加粗  
      builder.gimp(new RippleGimpyRenderer());  
        // 加网--第一个参数是横线颜色，第二个参数是竖线颜色  
        builder.gimp(new FishEyeGimpyRenderer());  
        // 加入阴影效果 默认3，75  
        //builder.gimp(new DropShadowGimpyRenderer());  
  
        for (int i=0; i<_pngcnt; i++) {
          Captcha captcha = builder.build();  
          String ans = captcha.getAnswer();
          System.out.println(ans);
          BufferedImage out_png = captcha.getImage();
          try { 
          ImageIO.write(out_png,"png",new File("/home/tracyhe/data_download/simplecaptcha_generate/"+ans+".png"));  
          } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
          }
        }
         
  
    } 

  public static void main(String[] args) {
    System.out.println("Hello World!");
    CaptchaTest test = new CaptchaTest();
    for (int i=0; i<10000; i++) { 
      test.showCaptcha();
    }
  }
} 

