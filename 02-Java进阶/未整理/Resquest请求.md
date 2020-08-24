# request.getReader()的作用

from https://blog.csdn.net/qq_36719449/article/details/82820760

    背景: 在原生Servlet中 发现从request获取参数 有的用 getParma 有的用 getReader()

转载自 https://www.cnblogs.com/doit8791/p/7658814.html

application/x- www-form-urlencoded是Post请求默认的请求体内容类型，也是form表单默认的类型。Servlet API规范中对该类型的请求内容提供了request.getParameter()方法来获取请求参数值。但当请求内容不是该类型时，需要调用request.getInputStream()或request.getReader()方法来获取请求内容值。

当请求体内容（注意：get请求没有请求体）类型是application/x- www-form-urlencoded时也可以直接调用request.getInputStream()或request.getReader()方法获取到请求内容再解析出具体都参数，但前提是还没调用request.getParameter()方法。此时当request.getInputStream()或request.getReader()获取到请求内容后，无法再调request.getParameter()获取请求内容。即对该类型的请求，三个方法互斥，只能调其中一个。今天遇到一个Controller请求经过Spring MVC 的RequestMapping处理后，只能通过request.getParameter()获取到参数、无法通过request.getInputStream()和request.getReader()读取内容很可能就是因为在请求经过Spring MVC时已调用过request.getParameter()方法的原因。

注意：在一个请求链中，请求对象被前面对象方法中调用request.getInputStream()或request.getReader()获取过内容后，后面的对象方法里再调用这两个方法也无法获取到客户端请求的内容，但是调用request.getParameter()方法获取过内容后，后面的对象方法里依然可以调用它获取到参数的内容。

当请求体内容是其它类型时，比如 multipart/form-data或application/json时，无法通过request.getParameter()获取到请求内容，此时只能通过request.getInputStream()和request.getReader()方法获取请求内容，此时调用request.getParameter()也不会影响第一次调用request.getInputStream()或request.getReader()获取到请求内容。

request.getInputStream()返回请求内容字节流，多用于文件上传，request.getReader()是对前者返回内容的封装，可以让调用者更方便字符内容的处理（不用自己先获取字节流再做字符流的转换操作）。