ON ERROR RESUME NEXT

Dim VOL_PROD_KEY
if Wscript.arguments.count<1 then
VOL_PROD_KEY =InputBox("ʹ��˵����"&vbCr&vbCr&" �������Զ��滻�㵱ǰ Windows �����к�,ͨ��΢����֤��ȫ���档"&vbCr&vbCr&"���к�(OEM����Ч,Ĭ�ϰ汾Ϊ XP VLK)��"&vbCr&vbCr&"�������к�(Ĭ��Ϊ XP VLK)��","Windows XP/2003 ���кŸ�������","DP7CM-PD6MC-6BKXT-M8JJ6-RPXGJ")
if VOL_PROD_KEY="" then
Wscript.quit
end if
else
VOL_PROD_KEY = Wscript.arguments.Item(0)
end if

VOL_PROD_KEY = Replace(VOL_PROD_KEY,"-","") 'remove hyphens if any

for each Obj in GetObject("winmgmts:{impersonationLevel=impersonate}").InstancesOf ("win32_WindowsProductActivation")

result = Obj.SetProductKey (VOL_PROD_KEY)

if err = 0 then
Wscript.echo "���� Windows CD-KEY �޸ĳɹ�������ϵͳ���ԡ�"
end if

if err <> 0 then
Wscript.echo "�޸�ʧ�ܣ���������� CD-KEY �Ƿ��뵱ǰ Windows �汾��ƥ�䡣"
Err.Clear
end if

Next
