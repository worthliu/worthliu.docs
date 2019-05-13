## 序列化

`dubbo`中,对于远程请求访问时,需要传输参数进行序列化;

其提供的`Serialization`接口定义,默认实现的负载均衡算法为`hessian2`;

```
@SPI("hessian2")
public interface Serialization {

    byte getContentTypeId();

    String getContentType();

    @Adaptive
    ObjectOutput serialize(URL url, OutputStream output) throws IOException;

    @Adaptive
    ObjectInput deserialize(URL url, InputStream input) throws IOException;

}
```
`Serialization`依赖于`jdk`的`OutputStream`，`InputStream`，因为各具体的序列化工具依赖于`OutputStream`，`InputStream`。

又为了屏蔽各个序列化接口对`dubbo`侵入`dubbo`定义统一的`DataOutput`` DataInput`接口来适配各种序列化工具的输入输出；


其提供序列化算法:
+ `Hessian2Serialization` : 
+ `ProtostuffSerialization` : 
+ `GenericProtobufSerialization` : 
+ `FastJsonSerialization` : 
+ `KryoSerialization` : 
+ `GsonSerialization` : 
+ `AvroSerialization` : 
+ `JavaSerialization` : 
+ `NativeJavaSerialization` : 
+ `FstSerialization` : 
+ `CompactedJavaSerialization` :

###

```Hessian2Serialization
	public class Hessian2Serialization implements Serialization {

    @Override
    public byte getContentTypeId() {
        return NATIVE_HESSIAN_SERIALIZATION_ID;
    }

    @Override
    public String getContentType() {
        return "x-application/native-hessian";
    }

    @Override
    public ObjectOutput serialize(URL url, OutputStream out) throws IOException {
        return new Hessian2ObjectOutput(out);
    }

    @Override
    public ObjectInput deserialize(URL url, InputStream is) throws IOException {
        return new Hessian2ObjectInput(is);
    }

}
```

`Hessian2Serialization`构建基于`Hessian`的`Dubbo`接口`Output`,`Input`实现;

`Dubbo`是基于`Output`, `Input`接口操作不需要关心具体的序列化反序列化实现方式。

```
public class Hessian2ObjectOutput implements ObjectOutput {
    private final Hessian2Output output;

    public Hessian2ObjectOutput(OutputStream os) {
        output = new Hessian2Output(os);
        output.setSerializerFactory(Hessian2SerializerFactory.INSTANCE);
    }

    @Override
    public void writeBool(boolean v) throws IOException {
        output.writeBoolean(v);
    }

    @Override
    public void writeByte(byte v) throws IOException {
        output.writeInt(v);
    }

    @Override
    public void writeShort(short v) throws IOException {
        output.writeInt(v);
    }

    @Override
    public void writeInt(int v) throws IOException {
        output.writeInt(v);
    }

    @Override
    public void writeLong(long v) throws IOException {
        output.writeLong(v);
    }

    @Override
    public void writeFloat(float v) throws IOException {
        output.writeDouble(v);
    }

    @Override
    public void writeDouble(double v) throws IOException {
        output.writeDouble(v);
    }

    @Override
    public void writeBytes(byte[] b) throws IOException {
        output.writeBytes(b);
    }

    @Override
    public void writeBytes(byte[] b, int off, int len) throws IOException {
        output.writeBytes(b, off, len);
    }

    @Override
    public void writeUTF(String v) throws IOException {
        output.writeString(v);
    }

    @Override
    public void writeObject(Object obj) throws IOException {
        output.writeObject(obj);
    }

    @Override
    public void flushBuffer() throws IOException {
        output.flushBuffer();
    }
}
```

实际上：
+ 序列化：读取对象字段，按照一定格式写入文件或者其他承载媒介中；
+ 反序列化：利用反射机制生成类对象，从媒介中读取对象信息，将这些字段信息赋给对象