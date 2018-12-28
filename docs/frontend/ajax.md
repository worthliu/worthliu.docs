
**`ajax` 的全称是`Asynchronous JavaScript and XML`，其中，`Asynchronous`是异步的意思，它有别于传统web开发中采用的同步的方式。**

>+ 异步传输是面向字符的传输，它的单位是字符；
+ 而同步传输是面向比特的传输，它的单位是桢，它传输的时候要求接受方和发送方的时钟是保持一致的。

### AJAX

大家都知道`ajax`并非一种新的技术，而是几种原有技术的结合体。它由下列技术组合而成。
>1. 使用`CSS`和`XHTML`来表示。
2. 使用`DOM`模型来交互和动态显示。
3. 使用`XMLHttpRequest`来和服务器进行异步通信。
4. 使用`javascript`来绑定和调用。

在上面几中技术中，除了`XmlHttpRequest`对象以外，其它所有的技术都是基于`web`标准并且已经得到了广泛使用的，`XMLHttpRequest`虽然目前还没有被`W3C`所采纳，但是它已经是一个事实的标准，因为目前几乎所有的主流浏览器都支持它

### Ajax的原理

**简单来说通过`XmlHttpRequest`对象来向服务器发异步请求，从服务器获得数据，然后用`javascript`来操作`DOM`而更新页面。这其中最关键的一步就是从服务器获得请求数据。**

`XMLHttpRequest`是`ajax`的核心机制，它是在IE5中首先引入的，是一种支持异步请求的技术。

简单的说，也就是`javascript`可以及时向服务器提出请求和处理响应，而不阻塞用户。达到无刷新的效果。

首先，我们先来看看`XMLHttpRequest`这个对象的属性。
>它的属性有：
+ `onreadystatechange` ：每次状态改变所触发事件的事件处理程序。
+ `responseText` ：从服务器进程返回数据的字符串形式。
+ `responseXML` ：从服务器进程返回的DOM兼容的文档数据对象。
+ `status` ：从服务器返回的数字代码，比如常见的`404`（未找到）和`200`（已就绪）
+ `status Text` ：伴随状态码的字符串信息
+ `readyState` ：对象状态值
   + `0` ：(未初始化) 对象已建立，但是尚未初始化（尚未调用`open`方法）
   + `1` ：(初始化) 对象已建立，尚未调用`send`方法
   + `2` ：(发送数据) `send`方法已调用，但是当前的状态及`http`头未知
   + `3` ：(数据传送中) 已接收部分数据，因为响应及`http`头不全，这时通过`responseBody`和`responseText`获取部分数据会出现错误，
   + `4` ：(完成) 数据接收完毕,此时可以通过通过`responseXml`和`responseText`获取完整的回应数据

```
function CreateXmlHttp() {
    //非IE浏览器创建XmlHttpRequest对象
    if (window.XmlHttpRequest) {
        xmlhttp = new XmlHttpRequest();
    }

    //IE浏览器创建XmlHttpRequest对象
    if (window.ActiveXObject) {
        try {
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
        } catch (e) {
            try {
                xmlhttp = new ActiveXObject("msxml2.XMLHTTP");
            } catch (ex) { }
        }
    }
}
```

```
function Ustbwuyi() {
    var data = document.getElementById("username").value;
    CreateXmlHttp();
    if (!xmlhttp) {
        alert("创建xmlhttp对象异常！");
        return false;
    }

    xmlhttp.open("POST", url, false);

    xmlhttp.onreadystatechange = function () {
        if (xmlhttp.readyState == 4) {
            document.getElementById("user1").innerHTML = "数据正在加载...";
            if (xmlhttp.status == 200) {
                document.write(xmlhttp.responseText);
            }
        }
    }
    xmlhttp.send();
}

```