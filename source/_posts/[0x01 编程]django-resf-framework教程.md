---
title: 【编程】django resf framework教程
date: 2021-04-23 11:36:59
categories: 编程
tags: Python
---

# Django Resf Framework教程


本教程主要为翻译官方教程，用来快速熟悉如何在django上使用REST framework

官网教程：https://www.django-rest-framework.org/tutorial/quickstart/

Github对应仓库： https://github.com/JeffXue/django-resf-framework-tutorial
> 18年的记录，当前进一步同步到博客中，可能内容跟当前官方最新版本有出入

---

## quick start：快速开始
本章节主要从一个极小的应用去讲解所涉及到的相关内容
- 初始化django应用
- 使用`serializers.HyperlinkedModelSerializer`设置序列化类
- 使用`viewsets.ModelViewSet`设置视图集
- 使用`routers.DefaultRouter()`设置路由
- 配置`REST_FRAMEWORK`全局参数

### 初始化项目
```shell
# 新建项目及应用
django-admin.py startproject tutorial
cd tutorial
django-admin.py startapp quickstart

# 同步数据库，默认为db.sqllite3
python manage.py migrate

# 创建超级用户，即管理员用户
python manage.py createsuperuser

```

<!-- more -->

配置对应的app，打开`tutorial/settings.py`，添加对应的quickstart app
```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'quickstart',
]
```

### 序列化
新建`tutorial/quickstart/serializers.py的文件`，用于序列化数据
```python
from django.contrib.auth.models import User, Group
from rest_framework import serializers


# 继承HyperlinkedModelSerializer
class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        # 指定model
        model = User
        # 指定字段
        fields = ('url', 'username', 'email', 'groups')


class GroupSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Group
        fields = ('url', 'name')
```

### 配置视图
打开`tutorial/quickstart/views.py`文件

```python
from django.contrib.auth.models import User, Group
from rest_framework import viewsets
from tutorial.quickstart.serializers import UserSerializer, GroupSerializer

# 集成ModelViewSet
class UserViewSet(viewsets.ModelViewSet):
    """
    允许用户查看或编辑的API路径。
    """
    # 指定queryset数据
    queryset = User.objects.all().order_by('-date_joined')
    # 指定序列化类
    serializer_class = UserSerializer


class GroupViewSet(viewsets.ModelViewSet):
    """
    允许组查看或编辑的API路径。
    """
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
```

### 设置URL
打开`tutorial/urls.py`

```python
from django.conf.urls import url, include
from rest_framework import routers
from tutorial.quickstart import views

# 使用路由器类注册视图来自动生成API的URL conf
router = routers.DefaultRouter()
router.register(r'users', views.UserViewSet)
router.register(r'groups', views.GroupViewSet)

# 使用自动URL路由连接我们的API。
# 另外，我们还包括支持浏览器浏览API的登录URL。
urlpatterns = [
    url(r'^', include(router.urls)),
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework'))
]
```

### 设置

```python
INSTALLED_APPS = (
    ...
    'rest_framework',
)

REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAdminUser',
    ],
    'PAGE_SIZE': 10
}
```

---


## serialization：序列化
本教程将介绍如何创建一个简单的收录代码高亮展示的Web API。这个过程中, 将会介绍组成Rest框架的各个组件，并让你全面了解各个组件是如何一起工作的。
- 使用models.Model实现model类
- 使用serializers.ModelSerializer实现序列化类
- 使用序列化类编写常规views

### 新建snippet应用
```shell
python manage.py startapp snippets
```

添加app应用
```
INSTALLED_APPS = (
    ...
    'snippets',
)
```

### 创建model

```python
from django.db import models
from pygments.lexers import get_all_lexers
from pygments.styles import get_all_styles

LEXERS = [item for item in get_all_lexers() if item[1]]
LANGUAGE_CHOICES = sorted([(item[1][0], item[0]) for item in LEXERS])
STYLE_CHOICES = sorted((item, item) for item in get_all_styles())


class Snippet(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    title = models.CharField(max_length=100, blank=True, default='')
    code = models.TextField()
    linenos = models.BooleanField(default=False)
    language = models.CharField(choices=LANGUAGE_CHOICES, default='python', max_length=100)
    style = models.CharField(choices=STYLE_CHOICES, default='friendly', max_length=100)

    class Meta:
        ordering = ('created',)
```


```shell
python manage.py makemigrations snippets
python manage.py migrate
```

## 创建序列化类

为web api提供一种代码片段实例序列化和反序列化为`json`之类的表示形式的方式
在`snippets`目录下创建一个名为`serializers.py`

```python
from rest_framework import serializers
from snippets.models import Snippet, LANGUAGE_CHOICES, STYLE_CHOICES


class SnippetSerializer(serializers.Serializer):
    id = serializers.IntegerField(read_only=True)
    title = serializers.CharField(required=False, allow_blank=True, max_length=100)
    code = serializers.CharField(style={'base_template': 'textarea.html'})
    linenos = serializers.BooleanField(required=False)
    language = serializers.ChoiceField(choices=LANGUAGE_CHOICES, default='python')
    style = serializers.ChoiceField(choices=STYLE_CHOICES, default='friendly')

    def create(self, validated_data):
        """
        根据提供的验证过的数据创建并返回一个新的`Snippet`实例。
        """
        return Snippet.objects.create(**validated_data)

    def update(self, instance, validated_data):
        """
        根据提供的验证过的数据更新和返回一个已经存在的`Snippet`实例。
        """
        instance.title = validated_data.get('title', instance.title)
        instance.code = validated_data.get('code', instance.code)
        instance.linenos = validated_data.get('linenos', instance.linenos)
        instance.language = validated_data.get('language', instance.language)
        instance.style = validated_data.get('style', instance.style)
        instance.save()
        return instance
```


### 使用ModelSerializers

SnippetSerializer类中重复了很多包含在Snippet模型类（model）中的信息。如果能保证我们的代码整洁，那就更好了。
就像Django提供了Form类和ModelForm类一样，REST framework包括Serializer类和ModelSerializer类，
使用ModelSerializer类重构我们的序列化类

```python
class SnippetSerializer(serializers.ModelSerializer):
    class Meta:
        model = Snippet
        fields = ('id', 'title', 'code', 'linenos', 'language', 'style')

# 序列一个非常棒的属性就是可以通过打印序列化器类实例的结构(representation)查看它的所有字段。
from snippets.serializers import SnippetSerializer
serializer = SnippetSerializer()
print(repr(serializer))
# SnippetSerializer():
#    id = IntegerField(label='ID', read_only=True)
#    title = CharField(allow_blank=True, max_length=100, required=False)
#    code = CharField(style={'base_template': 'textarea.html'})
#    linenos = BooleanField(required=False)
#    language = ChoiceField(choices=[('Clipper', 'FoxPro'), ('Cucumber', 'Gherkin'), ('RobotFramework', 'RobotFramework'), ('abap', 'ABAP'), ('ada', 'Ada')...
#    style = ChoiceField(choices=[('autumn', 'autumn'), ('borland', 'borland'), ('bw', 'bw'), ('colorful', 'colorful')...
```

ModelSerializer类并不会做任何特别神奇的事情，它们只是创建序列化器类的快捷方式：
- 一组自动确定的字段。
- 默认简单实现的create()和update()方法。

### 使用序列化实现views
目标不会使用任何REST框架的其他功能，只需将视图作为常规django视图编写,`snippets/views.py`
```python
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.renderers import JSONRenderer
from rest_framework.parsers import JSONParser
from snippets.models import Snippet
from snippets.serializers import SnippetSerializer

class JSONResponse(HttpResponse):
    """
    An HttpResponse that renders its content into JSON.
    """
    def __init__(self, data, **kwargs):
        content = JSONRenderer().render(data)
        kwargs['content_type'] = 'application/json'
        super(JSONResponse, self).__init__(content, **kwargs)


@csrf_exempt
def snippet_list(request):
    """
    列出所有的code snippet，或创建一个新的snippet。
    """
    if request.method == 'GET':
        snippets = Snippet.objects.all()
        serializer = SnippetSerializer(snippets, many=True)
        return JSONResponse(serializer.data)

    elif request.method == 'POST':
        data = JSONParser().parse(request)
        serializer = SnippetSerializer(data=data)
        if serializer.is_valid():
            serializer.save()
            return JSONResponse(serializer.data, status=201)
        return JSONResponse(serializer.errors, status=400)


@csrf_exempt
def snippet_detail(request, pk):
    """
    获取，更新或删除一个 code snippet。
    """
    try:
        snippet = Snippet.objects.get(pk=pk)
    except Snippet.DoesNotExist:
        return HttpResponse(status=404)

    if request.method == 'GET':
        serializer = SnippetSerializer(snippet)
        return JSONResponse(serializer.data)

    elif request.method == 'PUT':
        data = JSONParser().parse(request)
        serializer = SnippetSerializer(snippet, data=data)
        if serializer.is_valid():
            serializer.save()
            return JSONResponse(serializer.data)
        return JSONResponse(serializer.errors, status=400)

    elif request.method == 'DELETE':
        snippet.delete()
        return HttpResponse(status=204)

```

### 添加URL
`snippets/urls.py`
```python
from snippets import views

urlpatterns = [
    url(r'^/$', views.snippet_list),
    url(r'^/(?P<pk>[0-9]+)/$', views.snippet_detail),
]
```

`tutorial/urls.py`
```python
from django.conf.urls import url, include

urlpatterns = [
    url(r'^', include('snippets.urls')),
]
```

到目前为止做得不错，我们有一个与Django的Forms API非常相似序列化API，和一些常规的Django视图

---

## requests and responses：请求及响应

现在开始，将真正开始接触REST框架的核心

### 请求对象（Request objects）
REST框架引入了一个扩展了常规`HttpRequest`的`Request`对象，并提供了更灵活的请求解析。`Request`对象的核心功能是`request.data`属性，它与`request.POST`类似，但对于使用Web API更为有用
```python
request.POST  # 只处理表单数据  只适用于'POST'方法
request.data  # 处理任意数据  适用于'POST'，'PUT'和'PATCH'方法
```

### 响应对象 （Response objects）
REST框架还引入了一个`Response`对象，这是一种获取未渲染（unrendered）内容的`TemplateResponse`类型，并使用内容协商来确定返回给客户端的正确内容类型。
```python
return Response(data)  # 渲染成客户端请求的内容类型。
```

### 状态码（Status）
视图（views）中使用纯数字的HTTP 状态码并不总是那么容易被理解。而且如果错误代码出错，很容易被忽略。REST框架为`statu`s模块中的每个状态代码（如`HTTP_400_BAD_REQUEST`）提供更明确的标识符。使用它们来代替纯数字的HTTP状态码是个很好的主意。


### 包装（wrapping）API视图
REST框架提供了两个可用于编写API视图的包装器（warppers）
- 基于函数视图的`@api_view`装饰器
- 基于类视图的`APIView`类
这些包装器提供了一些功能，例如确保你在视图中接收到`Request`实例，并将上下文添加到`Response`，以便可以执行内容协商。
包装器还提供了诸如在适当时候返回`405 Method Not Allowed`响应，并处理在使用格式错误的输入来访问`request.data`时发生的任何`ParseError`异常

### 组合在一起
使用新的组件重构之前的`snippets views`，之前的`view.py`中不再需要`JSONResponse`
```python
from rest_framework import status
from rest_framework.decorators import api_view
from rest_framework.response import Response
from snippets.models import Snippet
from snippets.serializers import SnippetSerializer


@api_view(['GET', 'POST'])
def snippet_list(request):
    """
    列出所有的snippets，或者创建一个新的snippet。
    """
    if request.method == 'GET':
        snippets = Snippet.objects.all()
        serializer = SnippetSerializer(snippets, many=True)
        return Response(serializer.data)

    elif request.method == 'POST':
        serializer = SnippetSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET', 'PUT', 'DELETE'])
def snippet_detail(request, pk):
    """
    获取，更新或删除一个snippet实例。
    """
    try:
        snippet = Snippet.objects.get(pk=pk)
    except Snippet.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)

    if request.method == 'GET':
        serializer = SnippetSerializer(snippet)
        return Response(serializer.data)

    elif request.method == 'PUT':
        serializer = SnippetSerializer(snippet, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    elif request.method == 'DELETE':
        snippet.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

```


### 添加可选的格式后缀
为了充分利用的响应不再与单一内容类型连接，可以为API路径添加对格式后缀的支持。
使用格式后缀给我们明确指定了给定格式的URL，这意味着API将能够处理诸如`http://example.com/api/items/4.json`之类的URL

视图中添加一个format的关键字参数
```python
def snippet_list(request, format=None):
    ...

def snippet_detail(request, pk, format=None):
    ...

```

`urls.py`文件，给现在的URL后面添加一组`format_suffix_patterns`

```python
from django.conf.urls import url
from rest_framework.urlpatterns import format_suffix_patterns
from snippets import views

urlpatterns = [
    url(r'^snippets/$', views.snippet_list),
    url(r'^snippets/(?P<pk>[0-9]+)$', views.snippet_detail),
]

urlpatterns = format_suffix_patterns(urlpatterns)
```


---

## class based views：基于类的视图


### 基于类的视图

可以使用基于类的视图编写我们的API视图，而不是基于函数的视图，继续重写`snippets/views.py`

```python
from snippets.models import Snippet
from snippets.serializers import SnippetSerializer
from django.http import Http404
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status


class SnippetList(APIView):
    """
    列出所有的snippets或者创建一个新的snippet。
    """
    def get(self, request, format=None):
        snippets = Snippet.objects.all()
        serializer = SnippetSerializer(snippets, many=True)
        return Response(serializer.data)

    def post(self, request, format=None):
        serializer = SnippetSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class SnippetDetail(APIView):
    """
    检索，更新或删除一个snippet示例。
    """
    def get_object(self, pk):
        try:
            return Snippet.objects.get(pk=pk)
        except Snippet.DoesNotExist:
            raise Http404

    def get(self, request, pk, format=None):
        snippet = self.get_object(pk)
        serializer = SnippetSerializer(snippet)
        return Response(serializer.data)

    def put(self, request, pk, format=None):
        snippet = self.get_object(pk)
        serializer = SnippetSerializer(snippet, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def delete(self, request, pk, format=None):
        snippet = self.get_object(pk)
        snippet.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

```

还需要重构`urls.py`，使用基于类的视图
```python
from django.conf.urls import url
from rest_framework.urlpatterns import format_suffix_patterns
from snippets import views

urlpatterns = [
    url(r'^snippets/$', views.SnippetList.as_view()),
    url(r'^snippets/(?P<pk>[0-9]+)/$', views.SnippetDetail.as_view()),
]

urlpatterns = format_suffix_patterns(urlpatterns)
```

### 使用mixins

使用的创建/获取/更新/删除操作和我们创建的任何基于模型的API视图非常相似。这些常见的行为是在REST框架的mixin类中实现的

听过mixin类重写`view.py`
使用`GenericAPIView`构建了我们的视图，并且用上了`ListModelMixin`和`CreateModelMixin`。
基类提供核心功能，而`mixin`类提供`.list()`和`.create()`操作。然后我们明确地将get和post方法绑定到适当的操作

```python
from snippets.models import Snippet
from snippets.serializers import SnippetSerializer
from rest_framework import mixins
from rest_framework import generics

class SnippetList(mixins.ListModelMixin,
                  mixins.CreateModelMixin,
                  generics.GenericAPIView):
    queryset = Snippet.objects.all()
    serializer_class = SnippetSerializer

    def get(self, request, *args, **kwargs):
        return self.list(request, *args, **kwargs)

    def post(self, request, *args, **kwargs):
        return self.create(request, *args, **kwargs)

```

使用GenericAPIView类来提供核心功能，并添加mixins来提供.retrieve()），.update()和.destroy()操作

```python
class SnippetDetail(mixins.RetrieveModelMixin,
                    mixins.UpdateModelMixin,
                    mixins.DestroyModelMixin,
                    generics.GenericAPIView):
    queryset = Snippet.objects.all()
    serializer_class = SnippetSerializer

    def get(self, request, *args, **kwargs):
        return self.retrieve(request, *args, **kwargs)

    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)
```

### 使用通用的基于类的视图

通过使用mixin类，我们使用更少的代码重写了这些视图，但我们还可以再进一步。
REST框架提供了一组已经混合好`（mixed-in）`的通用视图，我们可以使用它来简化我们的`views.py`模块。

```python
from snippets.models import Snippet
from snippets.serializers import SnippetSerializer
from rest_framework import generics


class SnippetList(generics.ListCreateAPIView):
    queryset = Snippet.objects.all()
    serializer_class = SnippetSerializer


class SnippetDetail(generics.RetrieveUpdateDestroyAPIView):
    queryset = Snippet.objects.all()
    serializer_class = SnippetSerializer
```



---

## authentication and permissions：认证和权限

本章节主要讲解的内容是：
- model添加关联外键：`owner`
- 更新序列化器：`owner`，指定source参数控制属性填充字段`owner.username`
- 将视图类和用户关联： 修改实例保存的方法`perform_create`，传入请求URL中隐含信息`self.request.user`
- 添加视图权限： `permission_classes`
- 自定义权限，添加自定义权限控制

目前，我们的API对谁可以编辑或删除代码段没有任何限制。我们希望有更高级的行为，以确保：
- 代码片段始终与创建者相关联。
- 只有通过身份验证的用户可以创建片段。
- 只有代码片段的创建者可以更新或删除它。
- 未经身份验证的请求应具有完全只读访问权限

### model添加信息关联信息
`snippet model`
```python
# owner为外键
owner = models.ForeignKey('auth.User', related_name='snippets', on_delete=models.CASCADE)
highlighted = models.TextField()


from pygments.lexers import get_lexer_by_name
from pygments.formatters.html import HtmlFormatter
from pygments import highlight

def save(self, *args, **kwargs):
    """
    使用`pygments`库创建一个高亮显示的HTML表示代码段。
    """
    lexer = get_lexer_by_name(self.language)
    linenos = self.linenos and 'table' or False
    options = self.title and {'title': self.title} or {}
    formatter = HtmlFormatter(style=self.style, linenos=linenos,
                              full=True, **options)
    self.highlighted = highlight(self.code, lexer, formatter)
    super(Snippet, self).save(*args, **kwargs)

```

### 添加用户序列化类及视图
`serializers.py`
```python
from django.contrib.auth.models import User

class UserSerializer(serializers.ModelSerializer):
    snippets = serializers.PrimaryKeyRelatedField(many=True, queryset=Snippet.objects.all())

    class Meta:
        model = User
        fields = ('id', 'username', 'snippets')
```


`view.py`
```python
from django.contrib.auth.models import User


class UserList(generics.ListAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer


class UserDetail(generics.RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

```

### 将snippet和用户关联

如果我们创建了一个代码片段，并不能将创建该代码片段的用户与代码段实例相关联。用户不是作为序列化表示的一部分发送的，而是作为传入请求的属性

我们处理的方式是在我们的代码片段视图中重写一个.perform_create()方法，这样我们可以修改实例保存的方法，并处理传入请求或请求URL中隐含的任何信息。

`views.py`
```python
def perform_create(self, serializer):
    serializer.save(owner=self.request.user)
```

序列化器的create()方法现在将被传递一个附加的'owner'字段以及来自请求的验证数据

### 更新snippet序列化器
`serializers.py`
```python
owner = serializers.ReadOnlyField(source='owner.username')
```

`source`参数控制哪个属性用于填充字段，并且可以指向序列化实例上的任何属性。它也可以采用如上所示点加下划线的方式，在这种情况下，它将以与Django模板语言一起使用的相似方式遍历给定的属性。

我们添加的字段是无类型的`ReadOnlyField`类，区别于其他类型的字段（如`CharField`，`BooleanField`等）。无类型的`ReadOnlyField`始终是只读的，只能用于序列化表示，不能用于在反序列化时更新模型实例。我们也可以在这里使用`CharField(read_only=True)``

### 添加视图所需权限

REST框架包括许多权限类，我们可以使用这些权限类来限制谁可以访问给定的视图。 在这种情况下，我们需要的是IsAuthenticatedOrReadOnly类，这将确保经过身份验证的请求获得读写访问权限，未经身份验证的请求将获得只读访问权限
`views.py`
```
from rest_framework import permissions

将以下属性添加到SnippetList和SnippetDetail视图类中
permission_classes = (permissions.IsAuthenticatedOrReadOnly,)

```

### 对象级别的权限

创建一个自定义权限，创建`permissions.py`
```python
from rest_framework import permissions


class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    自定义权限只允许对象的所有者编辑它。
    """

    def has_object_permission(self, request, view, obj):
        # 读取权限允许任何请求，
        # 所以我们总是允许GET，HEAD或OPTIONS请求。
        if request.method in permissions.SAFE_METHODS:
            return True

        # 只有该snippet的所有者才允许写权限。
        return obj.owner == request.user
```

添加自定义权限属性
```python
permission_classes = (permissions.IsAuthenticatedOrReadOnly,
                      IsOwnerOrReadOnly,)
```


### 使用API进行身份验证
现在因为我们在API上有一组权限，如果我们要编辑任何代码片段，我们都需要验证我们的请求。我们还没有设置任何身份验证类，所以应用的是默认的SessionAuthentication和BasicAuthentication。
当我们通过Web浏览器与API进行交互时，我们可以登录，然后浏览器会话将为请求提供所需的身份验证。
如果我们在代码中与API交互，我们需要在每次请求上显式提供身份验证凭据

```shell
http -a tom:password123 POST http://127.0.0.1:8000/snippets/ code="print 789"

{
    "id": 5,
    "owner": "tom",
    "title": "foo",
    "code": "print 789",
    "linenos": false,
    "language": "python",
    "style": "friendly"
}
```


---

## relationships and hyperlinked apis：关联与超链接API
通过使用hyperlinked来提供api的内部联系

本章节主要讲解内容包括：
- 使用`@api_view`方式创建一个根路径
- 添加代码高亮视图
- 添加根路径和代码高亮的url路径
- 使用HyperlinkedModelSerializer重写序列化类，并增加了highlight超链接属性，并通过view-name关联api
- 配置url name属性

### 为API创建一个根路径
现在有snippets和users路径，api没有一个入口点，使用一个常规的基于函数的视图和`@api_view`装饰器创建

`snippets/views.py`
```python
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.reverse import reverse


@api_view(['GET'])
def api_root(request, format=None):
    return Response({
        'users': reverse('user-list', request=request, format=format),
        'snippets': reverse('snippet-list', request=request, format=format)
    })
```
`reverse`返回完全限定的URL，URL模式是通过名称来标识的

### 为高亮显示代码片段创建路径
api中缺少代码高亮显示路径，REST框架提供了两种HTML渲染，一种使用模板渲染的HTML，另一种预渲染的HTML

使用基类来标识实例，并创建自己的`.get()`方法

`snippets/views.py`
```python
from rest_framework import renderers
from rest_framework.response import Response

class SnippetHighlight(generics.GenericAPIView):
    queryset = Snippet.objects.all()
    renderer_classes = (renderers.StaticHTMLRenderer,)

    def get(self, request, *args, **kwargs):
        snippet = self.get_object()
        return Response(snippet.highlighted)
```

`snippets/urls`添加url模式
```python
url(r'^$', views.api_root),
url(r'^snippets/(?P<pk>[0-9]+)/highlight/$', views.SnippetHighlight.as_view()),
```

### 超链接API

处理好实体之间的关系是api设计中更具挑战性的方面，可以选择几种不同的方式来代表一种关系
- 使用主键
- 实体之间使用超链接
- 在相关实体上使用唯一的标识字段
- 使用相关实体的默认字符串表示形式
- 将相关实体嵌套在父表示中
- 一些其他自定义表示

REST框架支持所有这些方式，并且可以将它们应用于正向或反向关系，也可以在诸如通用外键之类的自定义管理器上应用。

在这种情况下，希望在实体之间使用超链接方式。这样的话，需要修改序列化程序来扩展`HyperlinkedModelSerializer`而不是现有的`ModelSerializer`。

`HyperlinkedModelSerializer`与`ModelSerializer`有以下区别：
- 默认情况下不包括`id`字段。
- 它包含一个`url`字段，使用`HyperlinkedIdentityField`。
- 关联关系使用`HyperlinkedRelatedField`，而不是`PrimaryKeyRelatedField`。

可以轻松地重写我们现有的序列化程序以使用超链接。在你的`snippets/serializers.py`中添加
```python
class SnippetSerializer(serializers.HyperlinkedModelSerializer):
    owner = serializers.ReadOnlyField(source='owner.username')
    highlight = serializers.HyperlinkedIdentityField(view_name='snippet-highlight', format='html')

    class Meta:
        model = Snippet
        fields = ('url', 'id', 'highlight', 'owner',
                  'title', 'code', 'linenos', 'language', 'style')


class UserSerializer(serializers.HyperlinkedModelSerializer):
    snippets = serializers.HyperlinkedRelatedField(many=True, view_name='snippet-detail', read_only=True)

    class Meta:
        model = User
        fields = ('url', 'id', 'username', 'snippets')
```
`highlight`字段与`url`字段的类型相同，不同之处在于指向`snippet-highlight`url模式，而不是`snippet-detail`url模式

### 为URL模式命名
`snippets/urls.py`
```python
from django.conf.urls import url, include
from rest_framework.urlpatterns import format_suffix_patterns
from snippets import views

# API endpoints
urlpatterns = format_suffix_patterns([
    url(r'^$', views.api_root),
    url(r'^snippets/$',
        views.SnippetList.as_view(),
        name='snippet-list'),
    url(r'^snippets/(?P<pk>[0-9]+)/$',
        views.SnippetDetail.as_view(),
        name='snippet-detail'),
    url(r'^snippets/(?P<pk>[0-9]+)/highlight/$',
        views.SnippetHighlight.as_view(),
        name='snippet-highlight'),
    url(r'^users/$',
        views.UserList.as_view(),
        name='user-list'),
    url(r'^users/(?P<pk>[0-9]+)/$',
        views.UserDetail.as_view(),
        name='user-detail')
])

# 可浏览API的登录和注销视图
urlpatterns += [
    url(r'^api-auth/', include('rest_framework.urls',
                               namespace='rest_framework')),
]
```

---

## viewsets and routers：视图集和路由器

本章节主要讲解：
- 使用viewset重构之前的views
- 使用路由器配置url


REST框架包括一个用于处理`ViewSets`的抽象，它允许开发人员集中精力对API的状态和交互进行建模，并根据常规约定自动处理URL构造。

`ViewSet`类与`View`类几乎相同，不同之处在于它们提供诸如`read`或`update`之类的操作，而不是`get`或`put`等方法处理程序。

最后一个`ViewSet`类只绑定到一组方法处理程序，当它被实例化成一组视图的时候，通常通过使用一个`Router`类来处理自己定义URL conf的复杂性。

### 使用ViewSets重构
将`UserList`和`UserDetail`视图重构为一个`UserViewSet`
```python
from rest_framework import viewsets

class UserViewSet(viewsets.ReadOnlyModelViewSet):
    """
    此视图自动提供`list`和`detail`操作。
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer

```
使用`ReadOnlyModelViewSet`类来自动提供默认的“只读”操作。仍然像使用常规视图那样设置`queryset`和`serializer_class`属性，但不再需要向两个不同的类提供相同的信息

替换`SnippetList`，`SnippetDetail`和`SnippetHighlight`视图类

```python
class SnippetViewSet(viewsets.ModelViewSet):
    """
    此视图自动提供`list`，`create`，`retrieve`，`update`和`destroy`操作。

    另外我们还提供了一个额外的`highlight`操作。
    """
    queryset = Snippet.objects.all()
    serializer_class = SnippetSerializer
    permission_classes = (permissions.IsAuthenticatedOrReadOnly,
                          IsOwnerOrReadOnly,)

    @detail_route(renderer_classes=[renderers.StaticHTMLRenderer])
    def highlight(self, request, *args, **kwargs):
        snippet = self.get_object()
        return Response(snippet.highlighted)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

```
这次使用了`ModelViewSet`类来获取完整的默认读写操作。

还使用`@detail_route`装饰器创建一个名为`highlight`的自定义操作。这个装饰器可用于添加不符合标准create/update/delete样式的任何自定义路径。

默认情况下，使用`@detail_route`装饰器的自定义操作将响应GET请求。如果我们想要一个响应POST请求的动作，我们可以使用methods参数。

默认情况下，自定义操作的URL取决于方法名称本身。如果要更改URL的构造方式，可以为装饰器设置url_path关键字参数

### 将ViewSets绑定到URL

```python
from snippets.views import SnippetViewSet, UserViewSet, api_root
from rest_framework import renderers

snippet_list = SnippetViewSet.as_view({
    'get': 'list',
    'post': 'create'
})
snippet_detail = SnippetViewSet.as_view({
    'get': 'retrieve',
    'put': 'update',
    'patch': 'partial_update',
    'delete': 'destroy'
})
snippet_highlight = SnippetViewSet.as_view({
    'get': 'highlight'
}, renderer_classes=[renderers.StaticHTMLRenderer])
user_list = UserViewSet.as_view({
    'get': 'list'
})
user_detail = UserViewSet.as_view({
    'get': 'retrieve'
})

urlpatterns = format_suffix_patterns([
    url(r'^$', api_root),
    url(r'^snippets/$', snippet_list, name='snippet-list'),
    url(r'^snippets/(?P<pk>[0-9]+)/$', snippet_detail, name='snippet-detail'),
    url(r'^snippets/(?P<pk>[0-9]+)/highlight/$', snippet_highlight, name='snippet-highlight'),
    url(r'^users/$', user_list, name='user-list'),
    url(r'^users/(?P<pk>[0-9]+)/$', user_detail, name='user-detail')
])

```

### 使用路由器
使用的是ViewSet类而不是View类，实际上不需要自己设计URL，将资源连接到视图和url的约定，可以使用router类自动处理

重写`url.py`
```python
from django.conf.urls import url, include
from snippets import views
from rest_framework.routers import DefaultRouter

# 创建路由器并注册我们的视图。
router = DefaultRouter()
router.register(r'snippets', views.SnippetViewSet)
router.register(r'users', views.UserViewSet)

# API URL现在由路由器自动确定。
# 另外，我们还要包含可浏览的API的登录URL。
urlpatterns = [
    url(r'^', include(router.urls)),
    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework'))
]
```
使用路由器注册`viewsets`类似于提供`urlpattern`。我们包含两个参数 - 视图的URL前缀和视图本身。

我们使用的`DefaultRouter`类也会自动为我们创建API根视图，因此我们现在可以从我们的`views`模块中删除`api_root`方法

### View vs ViewSets

使用视图集可以是一个非常有用的抽象。它有助于确保URL约定在你的API中保持一致，最大限度地减少编写所需的代码量，让你能够专注于API提供的交互和表示，而不是URLconf的细节。

这并不意味着采用视图集总是正确的方法。在使用基于类的视图而不是基于函数的视图时，有一个类似的权衡要考虑。使用视图集不像单独构建视图那样明确


---

## schemas and client libraries：概要和客户端库

概要是一种机器可读文档，用于描述可用的API路径，其URLS以及它们支持的操作。

概要可以是自动生成文档的有用工具，也可以用于驱动可以与API进行交互的动态客户端库。

### Core API

为了提供概要支持REST框架使用`Core API`。

Core API是用于描述API的文档规范。它用于提供可用路径的内部表示形式和API公开的可能的交互。它可以用于服务器端或客户端。

当使用服务器端时，coreAPI允许API支持呈现范围广泛的概要或超媒体格式。

当使用客户端时，核心API允许动态驱动的客户端库，它可以与任何公开受支持的概要或超媒体格式的API交互。


### 添加概要

REST框架支持明确定义的概要视图或自动生成的概要。由于我们使用的是视图集和路由器，我们可以简单地使用自动概要生成。

你需要安装`coreapi` python包才能包含API概要

通过再URL配置上包括一个自动生成概要视图来为API添加概要

```python
from rest_framework.schemas import get_schema_view

schema_view = get_schema_view(title='Pastebin API')

urlpatterns = [
    url('^schema/$', schema_view),
    ...
]
```

---
