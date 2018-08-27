
# Preview Concourse pipelines in ATOM

If you use the ATOM editor for coding Concourse pipelines, then there is a great tool available to preview pipelines directly from the editor's user interface: the [concourse-vis plugin](https://atom.io/packages/concourse-vis) by danhigham.

The plugin allows you to visualize an entire CI pipeline, to pan and zoom into specific sections of it and also to click-and-jump into the the corresponding source code section of any resource that you click on the pipeline graph (which in my opinion is one of the best features of the plugin, as it makes navigation through a pipeline's source code a lot easier).

![ATOM plugin](https://github.com/lsilvapvt/misc-support-files/raw/master/docs/images/atom-plugin01.gif)
*Preview Concourse CI pipelines in the ATOM editor*


### Installing the Concourse-vis plugin

1. In the ATOM user interface, go to the editor's "Preferences" ("Settings") page  

2. Click on Install  

3. Search for "concourse" and you should see the "concourse-vis" plugin listed in the results  

4. Click on the "Install" button for that plugin and voilà, you are done.  

![ATOM plugin](https://github.com/lsilvapvt/misc-support-files/raw/master/docs/images/atom-plugin02.gif)

### Using the Concourse-vis plugin

1. In the ATOM user interface, while editing a Concourse pipeline YML file, activate the pipeline preview window using keys "Control + Alt + P"

2. From the pipeline preview window:  
  - pan an zoom in/out throughout the pipeline elements with your mouse  
  - click on elements/resources of the pipeline graph to jump right into the corresponding source code block  


---

#### [Back to Concourse Pipeline Hacks](..)
