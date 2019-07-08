## Django xadmin常见问题

[xadmin 常见问题](https://www.cnblogs.com/xingfuggz/p/10142388.html)
## Xadmin 错误:
源代码:

    def render(self, name, value, attrs=None):
        input_html = [ht for ht in super(AdminSplitDateTime, self).render(name, value, attrs).split('/><') if ht != '']
        # print(input_html)
        input_html[0] = input_html[0] + "/>"
        input_html[1] = "<" + input_html[1]

        return mark_safe(
            '<div class="datetime clearfix"><div class="input-group date bootstrap-datepicker"><span class="input-group-addon"><i class="fa fa-calendar"></i></span>%s'
            '<span class="input-group-btn"><button class="btn btn-default" type="button">%s</button></span></div>'
            '<div class="input-group time bootstrap-clockpicker"><span class="input-group-addon"><i class="fa fa-clock-o">'
            '</i></span>%s<span class="input-group-btn"><button class="btn btn-default" type="button">%s</button></span></div></div>' % (
                input_html[0], _(u'Today'), input_html[1], _(u'Now')))

input_html列表的内容:(主要就是把两个input拆分出来)

    源代码: input_html = [ht for ht in super(AdminSplitDateTime, self).render(name, value, attrs).split('/><') if ht != '']
    `/>\n\n<input` 分隔符已经改变了，这个地方可以找到原因(.split('/>/>\n\n<<')),可以加解决掉异常问题

    ['<input type="text" name="PurchaseDate_0" value="2019-06-16" class="date-field form-control admindatewidget" size="10" id="id_PurchaseDate_0" />\n\n<input type="text" name="PurchaseDate_1" value="18:36:20" class="time-field form-control admintimewidget" size="8" id="id_PurchaseDate_1" />']


错误信息:

    IndexError at /xadmin/mwsApp/ordersmodel/34/update/
    list index out of range
    Request Method:	GET
    Request URL:	http://127.0.0.1:9000/xadmin/mwsApp/ordersmodel/34/update/
    Django Version:	2.0
    Exception Type:	IndexError
    Exception Value:
    list index out of range
    `Exception Location:	/Users/cuco/PycharmProjects/GosundMWSERP/extra_apps/xadmin/widgets.py in render, line 83`
    Python Executable:	/Users/cuco/PycharmProjects/GosundMWSERP/venv/bin/python

解决方案:
