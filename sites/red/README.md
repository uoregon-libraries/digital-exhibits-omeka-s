# Additional Config Information - Red Thread
There are two customized sections of the Red Thread site that aren't documented anywhere (custom theme and module settings). During the upgrade to Omeka-S 3.2.3 I found that this information is present in the sql dumps of the site. However, because some module/theme names changed from the previous version,they didn't automatically populate in the new version. Here are the settings for future reference.

## Theme Settings

### Footer Logos Content

```html
<div class="row">
<div class="col-4">
<img alt="Museum of Natural and Cultural History" draggable="false" src="https://redthread.uoregon.edu/files/original/9684a27d3c4e020a884061cffbc8ca7c52905d21.png">
</div>
<div class="col-4">
<img alt="University of Oregon Libraries" draggable="false" src="https://redthread.uoregon.edu/files/original/1dde8116eab02cac87545be4e1d93ef654b0bfe0.png">
</div>
<div class="col-4">
<img alt="Jordan Schnitzer Museum of Art" draggable="false" src="https://redthread.uoregon.edu/files/original/d45cfeb062715800079f8afd5916c73dbb5bfc39.png">
</div>
</div>
```

### Footer Sponsors Content

```html
```

### Footer Licensing Content

```html
<i class="fab fa-creative-commons fa-2x ml-2 mr-2"></i>
<i class="fab fa-creative-commons-by fa-2x ml-2 mr-2"></i>
<p>
<a draggable="false" href="https://creativecommons.org/licenses/by/4.0/" target="_blank">Attribution 4.0 International (CC BY 4.0)</a>
</p>
```

### Footer Citation Content

```txt
Keller, Vera (2018). Red Thread: A Journey Through Color. Published by Digital Scholarship Center, University of Oregon Libraries, Eugene OR [available at https://redthread.uoregon.edu/].
```

### Footer Copyright

```html
<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-4882028-5"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
 
  gtag('config', 'UA-4882028-5');
</script>
```

## CSS Editor

Settings for the CSS Editor module.

```css
a:link {
  text-decoration:underline
}

.site-title {
  display:none
}

img {
  padding:0 30px 30px
}

.resource-link img {
  padding:0 30px
}

div.light_khaki {
  height:600px;
  padding:30px
}

div.swatch_grid_container {
  background-color:#fbfbf9;
  border-top:1px solid #dedede;
  border-bottom:1px solid #dedede;
  width:100%;
  padding:30px 0
}

div.clearboth {
  clear:both
}

div.swatch_grid {
  float:left;
  width:25%;
  text-align:center
}

div.item-showcase {
  background-color:#fbfbf9
}

.item #item-linked {
  display:none
}

#search {
  display:none
}

div.footer {
  background-color:#edebe7;
  padding:30px 30px 0;
  min-height:400px
}

div.footer_left {
  float:left;
  min-width:70%
}

div.footer_right {
  float:left;
  min-width:30%
}

div.clear {
  clear:both
}

.red {
  color:#FF0000
}

@media screen and (max-width: 600px) {
  .navigation {
    margin-top:50px
  }
}
```
