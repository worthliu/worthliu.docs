
### 前言

Java 8会因为将lambdas，流，新的日期/时间模型和Nashorn JavaScript引擎引入Java而被记住。有些人还会记得Java 8，因为它引入了各种小但有用的功能，例如Base64 API。

### 什么是Base64？

Base64是一种二进制到文本编码方案，通过将二进制数据转换为基数-64表示，以可打印的ASCII字符串格式表示二进制数据。每个Base64数字恰好代表6位二进制数据。

在RFC 1421中首次描述了Base64（但没有命名）：Internet电子邮件的隐私增强：第一部分：消息加密和认证过程。

后来，它在RFC 2045中正式呈现为Base64 ：多用途Internet邮件扩展（MIME）第一部分：Internet消息体的格式，

随后在RFC 4648：Base16，Base32和Base64数据编码中重新访问。

Base64用于防止数据在传输过程中通过信息系统（例如电子邮件）进行修改，这些信息系统可能不是8-bit clean（它们可能是8位值）。例如，您将图像附加到电子邮件消息，并希望图像到达另一端而不会出现乱码。您的电子邮件软件对图像进行Base64编码并将等效文本插入到邮件中，如下图所示：

```
Content-Disposition: inline;
	filename=IMG_0006.JPG
Content-Transfer-Encoding: base64

/9j/4R/+RXhpZgAATU0AKgAAAAgACgEPAAIAAAAGAAAAhgEQAAIAAAAKAAAAjAESAAMAAAABAAYA
AAEaAAUAAAABAAAAlgEbAAUAAAABAAAAngEoAAMAAAABAAIAAAExAAIAAAAHAAAApgEyAAIAAAAU
AAAArgITAAMAAAABAAEAAIdpAAQAAAABAAAAwgAABCRBcHBsZQBpUGhvbmUgNnMAAAAASAAAAAEA
...
NOMbnDUk2bGh26x2yiJcsoBIrvtPe3muBbTRGMdeufmH+Nct4chUXpwSPk/qK9GtJRMWWVFbZ0JH
I4rf2dkZSbOjt7hhEzwcujA4I7Gust75pYVwAPpXn+kzNLOVYD7xFegWEKPkHsM/pU1F0NKbNS32
o24sSCOlaaFYLUhjky4x9PSsKL5bJsdWkAz3xirH2dZLy1DM2C44zx1FZqL2PTXY/9k=

```

插图显示此编码图像以/开头和结尾=。在...表明未展示的文字。请注意，此示例或任何其他示例的整个编码比原始二进制数据大大约33％。收件人的电子邮件软件将对编码的文本图像进行Base64解码，以恢复原始二进制图像。对于此示例，图像将与消息的其余部分一起显示。

### Base64编码和解码
Base64依赖于简单的编码和解码算法。它们使用65个字符的`US-ASCII`子集，其中前64个字符中的每一个都映射到**等效的6位二进制序列**。

这是字母表：

```
Value Encoding  Value Encoding  Value Encoding  Value Encoding
    0 A            17 R            34 i            51 z
    1 B            18 S            35 j            52 0
    2 C            19 T            36 k            53 1
    3 D            20 U            37 l            54 2
    4 E            21 V            38 m            55 3
    5 F            22 W            39 n            56 4
    6 G            23 X            40 o            57 5
    7 H            24 Y            41 p            58 6
    8 I            25 Z            42 q            59 7
    9 J            26 a            43 r            60 8
   10 K            27 b            44 s            61 9
   11 L            28 c            45 t            62 +
   12 M            29 d            46 u            63 /
   13 N            30 e            47 v
   14 O            31 f            48 w         (pad) =
   15 P            32 g            49 x
   16 Q            33 h            50 y

```

**第65个字符（=）用于将Base64编码的文本填充到整数大小**，如下所述。

编码算法接收8位字节的输入流。假定该流首先以最高有效位排序：第一位是第一个字节中的高位，第八位是该字节中的低位，依此类推。

从左到右，这些字节被组织成**24位组**。每组被视为四个连接的6位组。每个6位组索引为64个可打印字符的数组; 输出结果字符。

当在编码数据的末尾有少于24位可用时，添加零位（在右侧）以形成整数个6位组。然后，可以输出一个或两个=填充字符。有两种情况需要考虑：
+ 一个剩余字节：将四个零位附加到该字节以形成两个6位组。每个组索引数组并输出结果字符。在这两个字符之后，输出两个=填充字符。
+ 剩下的两个字节：两个零位附加到第二个字节，形成三个6位组。每个组索引数组并输出结果字符。在这三个字符之后，输出一个=填充字符。

让我们考虑三个例子来了解编码算法的工作原理。首先，假设我们希望编码`@!*`：

```
Source ASCII bit sequences with prepended 0 bits to form 8-bit bytes:

@        !        *
01000000 00100001 00101010

Dividing this 24-bit group into four 6-bit groups yields the following:

010000 | 000010 | 000100 | 101010

These bit patterns equate to the following indexes:

16 2 4 42

Indexing into the Base64 alphabet shown earlier yields the following encoding:

QCEq

```

我们将继续将输入序列缩短为`@!`：

```
Source ASCII bit sequences with prepended 0 bits to form 8-bit bytes:

@        !       
01000000 00100001

Two zero bits are appended to make three 6-bit groups:

010000 | 000010 | 000100

These bit patterns equate to the following indexes:

16 2 4

Indexing into the Base64 alphabet shown earlier yields the following encoding:

QCE

An = pad character is output, yielding the following final encoding:

QCE=

```

最后一个示例将输入序列缩短为`@`：

```
Source ASCII bit sequence with prepended 0 bits to form 8-bit byte:

@       
01000000

Four zero bits are appended to make two 6-bit groups:

010000 | 000000

These bit patterns equate to the following indexes:

16 0

Indexing into the Base64 alphabet shown earlier yields the following encoding:

QA

Two = pad characters are output, yielding the following final encoding:

QA==

```

解码算法是编码算法的逆。但是，检测到不在Base64字母表中的字符或填充字符数不正确时，可以自由采取适当的措施。

### Base64变种

已经设计了几种Base64变体。一些变体要求编码的输出流被分成多行固定长度，每行不超过一定的长度限制，并且（最后一行除外）通过行分隔符与下一行分开（回车\r后跟一行换行\n）。我描述了Java 8的Base64 API支持的三种变体。查看Wikipedia的Base64条目以获取完整的变体列表。

#### Basic

RFC 4648描述了一种称为Basic的Base64变体。此变体使用RFC 4648和RFC 2045的表1中所示的Base64字母表（并在本文前面所示）进行编码和解码。编码器将编码的输出流视为一行; 没有输出行分隔符。解码器拒绝包含Base64字母表之外的字符的编码。请注意，可以覆盖这些和其他规定。

#### MIME

RFC 2045描述了一种称为MIME的Base64变体。此变体使用RFC 2045的表1中提供的Base64字母表进行编码和解码。编码的输出流被组织成不超过76个字符的行; 每行（最后一行除外）通过行分隔符与下一行分隔。解码期间将忽略Base64字母表中未找到的所有行分隔符或其他字符。

#### URL and Filename Safe

RFC 4648描述了一种称为URL和文件名安全的Base64变体。此变体使用RFC 4648的表2中提供的Base64字母表进行编码和解码。字母表与前面显示的字母相同，只是-替换+和_替换/。不输出行分隔符。解码器拒绝包含Base64字母表之外的字符的编码。

Base64编码在冗长的二进制数据和HTTP GET请求的上下文中很有用。我们的想法是对这些数据进行编码，然后将其附加到HTTP GET URL。如果使用Basic或MIME变体，则编码数据中的任何+或/字符必须被URL编码为十六进制序列（+变为%2B和/变为%2F）。生成的URL字符串会稍长一些。通过更换+同-和/同_，URL和文件名安全消除了对URL编码器/解码器（和它们的编码值的长度影响）的需要。此外，当编码数据用于文件名时，此变体很有用，因为Unix和Windows文件名不能包含/。


### 使用Java的Base64 API

Java 8引入一个Base64 API，包括java.util.Base64类及其嵌套static类Encoder和Decoder。Base64有几种获取编码器和解码器的static方法：

>+ `Base64.Encoder getEncoder()`：返回Basic变体的编码器。
+ `Base64.Decoder getDecoder()`：返回Basic变体的解码器。
+ `Base64.Encoder getMimeEncoder()`：返回MIME变体的编码器。
+ `Base64.Encoder getMimeEncoder(int lineLength, byte[] lineSeparator)`：返回具有给定lineLength的已修改MIME变体的编码器（向下舍入到最接近的4的倍数 - 输出在`lineLength<= 0` 时不分成行）和`lineSeparator`。
  + 当`lineSeparator`包含RFC 2045的表1中列出的任何Base64字母字符时，它会抛出`java.lang.IllegalArgumentException`。 
  + `getMimeEncoder()`方法返回的RFC 2045编码器是相当严格的。例如，该编码器创建具有76个字符的固定行长度（最后一行除外）的编码文本。
  + 如果您希望编码器支持RFC 1421，它指定固定行长度为64个字符，则需要使用`getMimeEncoder(int lineLength, byte[] lineSeparator)`。
+ `Base64.Decoder getMimeDecoder()`：返回MIME变体的解码器。
+ `Base64.Encoder getUrlEncoder()`：返回URL和Filename Safe变体的编码器。
+ `Base64.Decoder getUrlDecoder()`：返回URL和Filename Safe变体的解码器。

Base64.Encoder提出了几种用于编码字节序列的线程安全实例方法 将空引用传递给以下方法之一会导致`java.lang.NullPointerException`：

>+ `byte[] encode(byte[] src)`：将src所有字节编码到新分配的字节数组中，然后返回结果。
+ `int encode(byte[] src, byte[] dst)`：编码src所有字节到dst（开始于偏移0）。如果dst不足以保存编码，则抛出IllegalArgumentException。否则，返回写入dst的字节数。
+ `ByteBuffer encode(ByteBuffer buffer)`：将buffer所有剩余字节编码到新分配的java.nio.ByteBuffer对象中。返回后，buffer的position将更新到它的limit; 它的limit不会改变。返回的输出缓冲区的position将为零，其limit将是结果编码字节的数量。
+ `String encodeToString(byte[] src)`：将src所有字节编码为一个字符串，并返回该字符串。调用此方法等同于执行new String(encode(src), StandardCharsets.ISO_8859_1)。
+ `Base64.Encoder withoutPadding()`：返回与此编码器等效编码的编码器，但不在编码字节数据的末尾添加任何填充字符。
+ `OutputStream wrap(OutputStream os)`：包装输出流以编码字节数据。建议在使用后立即关闭返回的输出流，在此期间它会将所有可能的剩余字节刷新到底层输出流。关闭返回的输出流将关闭基础输出流。

Base64.Decoder提出了几种解码字节序列的线程安全实例方法。将空引用传递给以下方法之一会导致`NullPointerException`：

>+ `byte[] decode(byte[] src)`：将src所有字节解码为新分配的字节数组，然后返回。当Base64无效时抛出IllegalArgumentException。
+ `int decode(byte[] src, byte[] dst)`：解码src所有字节到dst（从偏移量0开始）。如果dst不足以保存解码，或者当Base64无效的时，抛出IllegalArgumentException。否则，返回写入dst的字节数。
+ `byte[] decode(String src)`：将src所有字节解码为新分配的字节数组，并返回该字节数组。调用此方法相当于调用decode(src.getBytes(StandardCharsets.ISO_8859_1))。当Base64无效时抛出IllegalArgumentException。
+ `ByteBuffer decode(ByteBuffer buffer)`：将buffer所有字节解码为新分配的java.nio.ByteBuffer对象。返回后，buffer其position将更新为它的limit; 它的limit不会改变。返回的输出缓冲区的position将为零，其limit将是生成的解码字节数。当Base64无效时抛出IllegalArgumentException。在这种情况下，buffer位置不会更新。
+ `InputStream wrap(InputStream is)`：包装输入流以解码字节数据。当输入Base64无效时，is对象的read()方法抛出java.io.IOException。关闭返回的输出流将关闭基础输出流。


#### 示例

```
        String msg = "Hello, Base64";
        Base64.Encoder encoder = Base64.getEncoder();
        byte[] encBytes = encoder.encode(msg.getBytes());
        for (int i = 0; i < encBytes.length; i++){
            System.out.printf("%c", encBytes[i]);
            if(i != 0 && i % 4 == 0){
                System.out.print(" ");
            }
        }
        System.out.println();
        Base64.Decoder decoder = Base64.getDecoder();
        byte[] decBytes = decoder.decode(encBytes);
        System.out.println(new String(decBytes));

```

```
SGVsb G8sI EJhc 2U2N A==
Hello, Base64
```