# Spring Security 如何添加登录验证码？松哥手把手教你给微人事添加登录验证码

登录添加验证码是一个非常常见的需求，网上也有非常成熟的解决方案。在传统的登录流程中加入一个登录验证码也不是难事，但是如何在 Spring Security 中添加登录验证码，对于初学者来说还是一件蛮有挑战的事情，因为默认情况下，在 Spring Security 中我们并不需要自己写登录认证逻辑，只需要自己稍微配置一下就可以了，所以如果要添加登录验证码，就涉及到如何在 Spring Security 即有的认证体系中，加入自己的验证逻辑。

学习本文，需要大家对 Spring Security 的基本操作有一些了解，如果大家对于 Spring Security 的操作还不太熟悉，可以在公众号后台回复 springboot，获取松哥纯手敲的 274 页免费 Spring Boot 学习干货。

好了，那么接下来，我们就来看下我是如何通过自定义过滤器给微人事添加上登录验证码的。

【[手把手视频教程链接](https://mp.weixin.qq.com/s/aaop_dS9UIOgTtQd0hl_tw)】

好了，不知道小伙伴们有没有看懂呢？视频中涉及到的所有代码我已经提交到 GitHub 上了：[github.com/lenve/vhr](https://github.com/lenve/vhr)。如果小伙伴们对完整的微人事视频教程感兴趣，可以点击这里:[Spring Boot + Vue 视频教程喜迎大结局，西交大的老师竟然都要来一套！](https://mp.weixin.qq.com/s/8FmgtWyz6HUIbF4smXQOwQ)

最后，还有一个去年写的关于验证码的笔记，小伙伴们也可以参考下。

### 准备验证码

要有验证码，首先得先准备好验证码，本文采用 Java 自画的验证码，代码如下：

```
/**
 * 生成验证码的工具类
 */
public class VerifyCode {

	private int width = 100;// 生成验证码图片的宽度
	private int height = 50;// 生成验证码图片的高度
	private String[] fontNames = { "宋体", "楷体", "隶书", "微软雅黑" };
	private Color bgColor = new Color(255, 255, 255);// 定义验证码图片的背景颜色为白色
	private Random random = new Random();
	private String codes = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
	private String text;// 记录随机字符串

	/**
	 * 获取一个随意颜色
	 * 
	 * @return
	 */
	private Color randomColor() {
		int red = random.nextInt(150);
		int green = random.nextInt(150);
		int blue = random.nextInt(150);
		return new Color(red, green, blue);
	}

	/**
	 * 获取一个随机字体
	 * 
	 * @return
	 */
	private Font randomFont() {
		String name = fontNames[random.nextInt(fontNames.length)];
		int style = random.nextInt(4);
		int size = random.nextInt(5) + 24;
		return new Font(name, style, size);
	}

	/**
	 * 获取一个随机字符
	 * 
	 * @return
	 */
	private char randomChar() {
		return codes.charAt(random.nextInt(codes.length()));
	}

	/**
	 * 创建一个空白的BufferedImage对象
	 * 
	 * @return
	 */
	private BufferedImage createImage() {
		BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
		Graphics2D g2 = (Graphics2D) image.getGraphics();
		g2.setColor(bgColor);// 设置验证码图片的背景颜色
		g2.fillRect(0, 0, width, height);
		return image;
	}

	public BufferedImage getImage() {
		BufferedImage image = createImage();
		Graphics2D g2 = (Graphics2D) image.getGraphics();
		StringBuffer sb = new StringBuffer();
		for (int i = 0; i < 4; i++) {
			String s = randomChar() + "";
			sb.append(s);
			g2.setColor(randomColor());
			g2.setFont(randomFont());
			float x = i * width * 1.0f / 4;
			g2.drawString(s, x, height - 15);
		}
		this.text = sb.toString();
		drawLine(image);
		return image;
	}

	/**
	 * 绘制干扰线
	 * 
	 * @param image
	 */
	private void drawLine(BufferedImage image) {
		Graphics2D g2 = (Graphics2D) image.getGraphics();
		int num = 5;
		for (int i = 0; i < num; i++) {
			int x1 = random.nextInt(width);
			int y1 = random.nextInt(height);
			int x2 = random.nextInt(width);
			int y2 = random.nextInt(height);
			g2.setColor(randomColor());
			g2.setStroke(new BasicStroke(1.5f));
			g2.drawLine(x1, y1, x2, y2);
		}
	}

	public String getText() {
		return text;
	}

	public static void output(BufferedImage image, OutputStream out) throws IOException {
		ImageIO.write(image, "JPEG", out);
	}
}

```

这个工具类很常见，网上也有很多，就是画一个简单的验证码，通过流将验证码写到前端页面，提供验证码的 Controller 如下：

```
@RestController
public class VerifyCodeController {
    @GetMapping("/vercode")
    public void code(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        VerifyCode vc = new VerifyCode();
        BufferedImage image = vc.getImage();
        String text = vc.getText();
        HttpSession session = req.getSession();
        session.setAttribute("index_code", text);
        VerifyCode.output(image, resp.getOutputStream());
    }
}

```

这里创建了一个 VerifyCode 对象，将生成的验证码字符保存到 session 中，然后通过流将图片写到前端，img 标签如下：

```
<img src="/vercode" alt="">

```

展示效果如下：



![img](https://user-gold-cdn.xitu.io/2020/3/3/1709e58c6e0ada1a?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



### 自定义过滤器

在登陆页展示验证码这个就不需要我多说了，接下来我们来看看如何自定义验证码处理器：

```
@Component
public class VerifyCodeFilter extends GenericFilterBean {
    private String defaultFilterProcessUrl = "/doLogin";

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        if ("POST".equalsIgnoreCase(request.getMethod()) && defaultFilterProcessUrl.equals(request.getServletPath())) {
            // 验证码验证
            String requestCaptcha = request.getParameter("code");
            String genCaptcha = (String) request.getSession().getAttribute("index_code");
            if (StringUtils.isEmpty(requestCaptcha))
                throw new AuthenticationServiceException("验证码不能为空!");
            if (!genCaptcha.toLowerCase().equals(requestCaptcha.toLowerCase())) {
                throw new AuthenticationServiceException("验证码错误!");
            }
        }
        chain.doFilter(request, response);
    }
}

```

自定义过滤器继承自 GenericFilterBean，并实现其中的 doFilter 方法，在 doFilter 方法中，当请求方法是 POST，并且请求地址是 `/doLogin` 时，获取参数中的 code 字段值，该字段保存了用户从前端页面传来的验证码，然后获取 session 中保存的验证码，如果用户没有传来验证码，则抛出验证码不能为空异常，如果用户传入了验证码，则判断验证码是否正确，如果不正确则抛出异常，否则执行 `chain.doFilter(request, response);` 使请求继续向下走。

### 配置

最后在 Spring Security 的配置中，配置过滤器，如下：

```
@Configuration
public class SecurityConfig extends WebSecurityConfigurerAdapter {

    @Autowired
    VerifyCodeFilter verifyCodeFilter;
    ...
    ...
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.addFilterBefore(verifyCodeFilter, UsernamePasswordAuthenticationFilter.class);
        http.authorizeRequests()
                .antMatchers("/admin/**").hasRole("admin")
                ...
                ...
                .permitAll()
                .and()
                .csrf().disable();
    }
}

```

这里只贴出了部分核心代码，即 `http.addFilterBefore(verifyCodeFilter, UsernamePasswordAuthenticationFilter.class);` ，如此之后，整个配置就算完成了。

接下来在登录中，就需要传入验证码了，如果不传或者传错，都会抛出异常，例如不传的话，抛出如下异常：



![img](https://user-gold-cdn.xitu.io/2020/3/3/1709e58c7079bb12?imageView2/0/w/1280/h/960/format/webp/ignore-error/1)



本文案例，我已经上传到 GitHub ，欢迎大家 star：[github.com/lenve/javab…](https://github.com/lenve/javaboy-code-samples)