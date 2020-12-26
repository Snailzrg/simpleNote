# Docker

# 在CentOS上安装Docker Engine

*预计阅读时间：10分钟*

要在CentOS上开始使用Docker Engine，请确保您 [满足先决条件](https://docs.docker.com/engine/install/centos/#prerequisites)，然后 [安装Docker](https://docs.docker.com/engine/install/centos/#installation-methods)。

## 前提条件

### 操作系统要求

要安装Docker Engine，您需要一个CentOS 7或8的维护版本。不支持或未测试存档版本。

该`centos-extras`库必须启用。默认情况下，此存储库是启用的，但是如果已禁用它，则需要 [重新启用它](https://wiki.centos.org/AdditionalResources/Repositories)。

`overlay2`建议使用存储驱动程序。

### 卸载旧版本

较旧的Docker版本称为`docker`或`docker-engine`。如果已安装这些程序，请卸载它们以及相关的依赖项。

```
$ sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine
```

如果`yum`报告未安装这些软件包，则可以。

的内容（`/var/lib/docker/`包括图像，容器，卷和网络）被保留。现在将Docker Engine软件包称为`docker-ce`。

## 安装方法

您可以根据需要以不同的方式安装Docker Engine：

- 大多数用户会 [设置Docker的存储库](https://docs.docker.com/engine/install/centos/#install-using-the-repository)并从中进行安装，以简化安装和升级任务。这是推荐的方法。
- 一些用户下载并[手动安装](https://docs.docker.com/engine/install/centos/#install-from-a-package)RPM软件包， 并完全手动管理升级。这在诸如在无法访问互联网的空白系统上安装Docker的情况下非常有用。
- 在测试和开发环境中，一些用户选择使用自动 [便利脚本](https://docs.docker.com/engine/install/centos/#install-using-the-convenience-script)来安装Docker。

### 使用存储库安装

在新主机上首次安装Docker Engine之前，需要设置Docker存储库。之后，您可以从存储库安装和更新Docker。

#### 设置存储库

安装`yum-utils`软件包（提供`yum-config-manager` 实用程序）并设置**稳定的**存储库。

```
$ sudo yum install -y yum-utils

$ sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

> **可选**：启用**每晚**或**测试**存储库。
>
> 这些存储库包含在`docker.repo`上面的文件中，但默认情况下处于禁用状态。您可以在稳定存储库旁边启用它们。以下命令启用**每晚**存储库。
>
> ```
> $ sudo yum-config-manager --enable docker-ce-nightly
> ```
>
> 要启用**测试**通道，请运行以下命令：
>
> ```
> $ sudo yum-config-manager --enable docker-ce-test
> ```
>
> 您可以通过运行带有标志的命令来禁用**夜间**或**测试**存储库 。要重新启用它，请使用该标志。以下命令禁用**夜间**存储库。`yum-config-manager``--disable``--enable`
>
> ```
> $ sudo yum-config-manager --disable docker-ce-nightly
> ```
>
> [了解**每晚**和**测试**频道](https://docs.docker.com/engine/install/)。

#### 安装DOCKER引擎

1. 安装*最新版本*的Docker Engine和容器，或转到下一步以安装特定版本：

   ```
   $ sudo yum install docker-ce docker-ce-cli containerd.io
   ```

   如果提示您接受GPG密钥，请验证指纹是否匹配 `060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35`，如果是，则接受它。

   > 有多个Docker存储库吗？
   >
   > 如果您启用了多个Docker存储库，则在未在`yum install`or `yum update`命令中指定版本的情况下进行安装或更新将始终安装可能的最高版本，这可能不适合您的稳定性需求。

   Docker已安装但尚未启动。`docker`创建该组，但没有用户添加到该组。

2. 要安装*特定版本*的Docker Engine，请在存储库中列出可用版本，然后选择并安装：

   一种。列出并排序您存储库中可用的版本。此示例按版本号（从高到低）对结果进行排序，并被截断：

   ```
   $ yum list docker-ce --showduplicates | sort -r
   
   docker-ce.x86_64  3:18.09.1-3.el7                     docker-ce-stable
   docker-ce.x86_64  3:18.09.0-3.el7                     docker-ce-stable
   docker-ce.x86_64  18.06.1.ce-3.el7                    docker-ce-stable
   docker-ce.x86_64  18.06.0.ce-3.el7                    docker-ce-stable
   ```

   返回的列表取决于启用了哪些存储库，并且特定于您的CentOS版本（`.el7`在本示例中以后缀表示）。

   b。通过其完全合格的软件包名称安装特定版本，该软件包名称是软件包名称（`docker-ce`）加上版本字符串（第二列），从第一个冒号（`:`）一直到第一个连字符，并用连字符（`-`）分隔。例如，`docker-ce-18.09.1`。

   ```
   $ sudo yum install docker-ce-<VERSION_STRING> docker-ce-cli-<VERSION_STRING> containerd.io
   ```

   Docker已安装但尚未启动。`docker`创建该组，但没有用户添加到该组。

3. 启动Docker

   ```
   $ sudo systemctl start docker
   ```

4. 通过运行`hello-world` 映像来验证是否正确安装了Docker Engine 。

   ```
   $ sudo docker run hello-world
   ```

   此命令下载测试图像并在容器中运行它。容器运行时，它会打印参考消息并退出。

Docker Engine已安装并正在运行。您需要使用`sudo`来运行Docker命令。继续进行[Linux后安装，](https://docs.docker.com/engine/install/linux-postinstall/)以允许非特权用户运行Docker命令以及其他可选配置步骤。

#### 升级DOCKER引擎

要升级Docker Engine，请按照[安装说明](https://docs.docker.com/engine/install/centos/#install-using-the-repository)，选择要安装的新版本。

### 从软件包安装

如果无法使用Docker的存储库安装Docker，则可以下载该`.rpm`发行版的 文件并手动安装。每次升级Docker Engine时，都需要下载一个新文件。

1. 转到https://download.docker.com/linux/centos/ 并选择您的CentOS版本。然后浏览`x86_64/stable/Packages/` 并下载`.rpm`您要安装的Docker版本的文件。

   > **注意**：要安装**夜间**或**测试**（预发布）软件包，`stable`请将上述URL中的单词更改为`nightly`或`test`。 [了解**每晚**和**测试**频道](https://docs.docker.com/engine/install/)。

2. 安装Docker Engine，将下面的路径更改为您下载Docker软件包的路径。

   ```
   $ sudo yum install /path/to/package.rpm
   ```

   Docker已安装但尚未启动。`docker`创建该组，但没有用户添加到该组。

3. 启动Docker

   ```
   $ sudo systemctl start docker
   ```

4. 通过运行`hello-world` 映像来验证是否正确安装了Docker Engine 。

   ```
   $ sudo docker run hello-world
   ```

   此命令下载测试图像并在容器中运行它。容器运行时，它会打印参考消息并退出。

Docker Engine已安装并正在运行。您需要使用`sudo`来运行Docker命令。继续[执行Linux的安装后步骤，](https://docs.docker.com/engine/install/linux-postinstall/)以允许非特权用户运行Docker命令以及其他可选配置步骤。

#### 升级DOCKER引擎

要升级Docker Engine，请下载更新的软件包文件，并使用 代替重复 [安装过程](https://docs.docker.com/engine/install/centos/#install-from-a-package)，并指向新文件。`yum -y upgrade``yum -y install`

### 使用便捷脚本安装

Docker在[get.docker.com](https://get.docker.com/) 和[test.docker.com上](https://test.docker.com/)提供了便利脚本，用于将Docker Engine-Community的边缘版本和测试版本快速且非交互地安装到开发环境中。脚本的源代码在 [`docker-install`存储库中](https://github.com/docker/docker-install)。 **不建议在生产环境中使用这些脚本**，并且在使用它们之前，您应该了解潜在的风险：

- 脚本需要运行`root`或具有`sudo`特权。因此，在运行脚本之前，应仔细检查和审核脚本。
- 这些脚本尝试检测Linux发行版和版本，并为您配置软件包管理系统。此外，脚本不允许您自定义任何安装参数。从Docker的角度或您自己组织的准则和标准的角度来看，这可能导致不支持的配置。
- 这些脚本将安装软件包管理器的所有依赖项和建议，而无需进行确认。这可能会安装大量软件包，具体取决于主机的当前配置。
- 该脚本未提供用于指定要安装哪个版本的Docker的选项，而是安装了在“ edge”通道中发布的最新版本。
- 如果已经使用其他机制将Docker安装在主机上，请不要使用便捷脚本。

本示例使用[get.docker.com](https://get.docker.com/)上的脚本在[Linux](https://get.docker.com/)上安装最新版本的Docker Engine-Community。要安装最新的测试版本，请改用[test.docker.com](https://test.docker.com/)。在下面的每个命令，取代每次出现`get`用`test`。

> **警告**：
>
> 在本地运行它们之前，请务必检查从Internet下载的脚本。

```
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh get-docker.sh

<output truncated>
```

如果您想以非root用户身份使用Docker，现在应该考虑使用类似以下方式将您的用户添加到“ docker”组：

```
  sudo usermod -aG docker your-user
```

请记住注销并重新登录才能生效！

> **警告**：
>
> 将用户添加到“泊坞窗”组后，他们可以运行容器，这些容器可用于在Docker主机上获得root特权。 有关更多信息，请参考 [Docker Daemon Attack Surface](https://docs.docker.com/engine/security/#docker-daemon-attack-surface)。

Docker Engine-社区已安装。它会自动在`DEB`基于分发的版本上启动。在 `RPM`基于发行版的系统上，您需要使用相应的`systemctl`或`service`命令手动启动它 。如消息所示，默认情况下，非root用户无法运行Docker命令。

> **注意事项**：
>
> 要安装没有root特权[的Docker](https://docs.docker.com/engine/security/rootless/)，请参阅 [以非root用户身份运行Docker守护程序（无根模式）](https://docs.docker.com/engine/security/rootless/)。
>
> 目前，无根模式是一项实验功能。

#### 使用便捷脚本后升级DOCKER

如果使用便捷脚本安装了Docker，则应直接使用包管理器升级Docker。重新运行便利程序脚本没有任何好处，并且如果尝试重新添加已经添加到主机的存储库，则可能导致问题。

## 卸载Docker 

1. 卸载Docker Engine，CLI和Containerd软件包：

   ```
   $ sudo yum remove docker-ce docker-ce-cli containerd.io
   ```

2. 主机上的映像，容器，卷或自定义配置文件不会自动删除。要删除所有图像，容器和卷：

   ```
   $ sudo rm -rf /var/lib/docker
   ```

您必须手动删除所有已编辑的配置文件。

## 下一步

- 继续[执行Linux的安装后步骤](https://docs.docker.com/engine/install/linux-postinstall/)。
- 复习“[使用Docker开发](https://docs.docker.com/develop/)”中的主题，以了解如何使用Docker构建新应用程序。

[需求](https://docs.docker.com/search/?q=requirements)，[apt](https://docs.docker.com/search/?q=apt)，[安装](https://docs.docker.com/search/?q=installation)，[centos](https://docs.docker.com/search/?q=centos)，[rpm](https://docs.docker.com/search/?q=rpm)，[安装](https://docs.docker.com/search/?q=install)，[卸载](https://docs.docker.com/search/?q=uninstall)，[升级](https://docs.docker.com/search/?q=upgrade)，[更新](https://docs.docker.com/search/?q=update)