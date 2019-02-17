# markdown样式

``` sh
python --version
# Python 2.7.13
pip --version
# pip 9.0.1
```

### 卡片样式

!!! warning "Installation on macOS"

    When you're running the pre-installed version of Python on macOS, `pip`
    tries to install packages in a folder for which your user might not have
    the adequate permissions. There are two possible solutions for this:

    1. **Installing in user space** (recommended): Provide the `--user` flag
      to the install command and `pip` will install the package in a user-site
      location. This is the recommended way.

    2. **Switching to a homebrewed Python**: Upgrade your Python installation
      to a self-contained solution by installing Python with Homebrew. This
      should eliminate a lot of problems you may be having with `pip`.

!!! failure "Error: unrecognized theme 'material'"

    If you run into this error, the most common reason is that you installed
    MkDocs through some package manager (e.g. Homebrew or `apt-get`) and the
    Material theme through `pip`, so both packages end up in different
    locations. MkDocs only checks its install location for themes.

!!! question "Why is there an edit button at the top of every article?"

    If the `repo_url` is set to a GitHub or BitBucket repository, and the
    `repo_name` is set to *GitHub* or *BitBucket* (implied by default), an
    edit button will appear at the top of every article. This is the automatic
    behavior that MkDocs implements. See the [MkDocs documentation][19] on more
    guidance regarding the `edit_uri` attribute, which defines whether the edit
    button is shown or not.

  [19]: https://www.mkdocs.org/user-guide/configuration/#edit_uri

#### 使用JavaScript操作按钮

> Default: `indigo`   | 左边显示的竖线

Click on a tile to change the primary color of the theme:

<button data-md-color-primary="red">Red</button>
<button data-md-color-primary="pink">Pink</button>
<button data-md-color-primary="purple">Purple</button>
<button data-md-color-primary="deep-purple">Deep Purple</button>
<button data-md-color-primary="indigo">Indigo</button>
<button data-md-color-primary="blue">Blue</button>
<button data-md-color-primary="light-blue">Light Blue</button>
<button data-md-color-primary="cyan">Cyan</button>
<button data-md-color-primary="teal">Teal</button>
<button data-md-color-primary="green">Green</button>
<button data-md-color-primary="light-green">Light Green</button>
<button data-md-color-primary="lime">Lime</button>
<button data-md-color-primary="yellow">Yellow</button>
<button data-md-color-primary="amber">Amber</button>
<button data-md-color-primary="orange">Orange</button>
<button data-md-color-primary="deep-orange">Deep Orange</button>
<button data-md-color-primary="brown">Brown</button>
<button data-md-color-primary="grey">Grey</button>
<button data-md-color-primary="blue-grey">Blue Grey</button>
<button data-md-color-primary="white">White</button>

<script>
  var buttons = document.querySelectorAll("button[data-md-color-primary]");
  Array.prototype.forEach.call(buttons, function(button) {
    button.addEventListener("click", function() {
      document.body.dataset.mdColorPrimary = this.dataset.mdColorPrimary;
    })
  })
</script>



#### 表格

> Default: `en`

<table style="white-space: nowrap;">
  <thead>
    <tr>
      <th colspan="4">Available languages</td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>ar</code> / Arabic</td>
      <td><code>ca</code> / Catalan</td>
      <td><code>cs</code> / Czech</td>
      <td><code>da</code> / Danish</td>
    </tr>
    <tr>
      <td><code>nl</code> / Dutch</td>
      <td><code>en</code> / English</td>
      <td><code>fi</code> / Finnish</td>
      <td><code>fr</code> / French</td>
    </tr>
    <tr>
      <td><code>gl</code> / Galician</td>
      <td><code>de</code> / German</td>
      <td><code>gr</code> / Greek</td>
      <td><code>he</code> / Hebrew</td>
    </tr>
    <tr>
      <td><code>hi</code> / Hindi</td>
      <td><code>hr</code> / Croatian</td>
      <td><code>hu</code> / Hungarian</td>
      <td><code>id</code> / Indonesian</td>
    </tr>
    <tr>
      <td><code>it</code> / Italian</td>
      <td><code>ja</code> / Japanese</td>
      <td><code>kr</code> / Korean</td>
      <td><code>no</code> / Norwegian</td>
    </tr>
    <tr>
      <td><code>fa</code> / Persian</td>
      <td><code>pl</code> / Polish</td>
      <td><code>pt</code> / Portugese</td>
      <td><code>ru</code> / Russian</td>
    </tr>
    <tr>
      <td><code>sr</code> / Serbian</td>
      <td><code>sh</code> / Serbo-Croatian</td>
      <td><code>sk</code> / Slovak</td>
      <td><code>es</code> / Spanish</td>
    </tr>
    <tr>
      <td><code>sv</code> / Swedish</td>
      <td><code>tr</code> / Turkish</td>
      <td><code>uk</code> / Ukrainian</td>
      <td><code>vi</code> / Vietnamese</td>
    </tr>
    <tr>
      <td colspan="2">
        <code>zh</code> / Chinese (Simplified)
      </td>
      <td colspan="2">
        <code>zh-Hant</code> / Chinese (Traditional)
      </td>
    </tr>
    <tr>
      <td colspan="2"><code>zh-TW</code> / Chinese (Taiwanese)</td>
      <td colspan="2" align="right">
        <a href="http://bit.ly/2EbzFc8">Submit a new language</a>
      </td>
    </tr>
  </tbody>
</table>
