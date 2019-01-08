
把字符串中每个空格替换成“%20”。例如输入“We are happy”，则输出“We%20are%20happy”

## solution

>+ 先遍历字符串所有空格，获取所有替换后字符串长度
+ 从后往前遍历替换空格；

```
public String replaceBlank(String target){
        if(target != null){
            StringBuilder sb = new StringBuilder();
            int indexOfOriginal = target.length() - 1;
            char[] tarCharArray = target.toCharArray();
            while (indexOfOriginal >= 0){
                if(tarCharArray[indexOfOriginal] == ' '){
                    sb.append('0');
                    sb.append('2');
                    sb.append('%');
                }else {
                    sb.append(tarCharArray[indexOfOriginal]);
                }
            }
            return sb.toString();
        }
        return "";
    }
```