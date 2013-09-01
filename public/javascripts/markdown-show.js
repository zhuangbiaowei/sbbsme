var opts = {
			  container: 'epiceditor',
			  basePath: '/epiceditor',
			  clientSideStorage: false,
			  localStorageName: 'epiceditor',
			  useNativeFullsreen: true,
			  parser: marked,
			  file: {
			    name: 'epiceditor',
			    defaultContent: '',
			    autoSave: 100
			  },
			  theme: {
			    base:'/themes/base/epiceditor.css',
			    preview:'/themes/preview/preview-dark.css',
			    editor:'/themes/editor/epic-dark.css'
			  },
			  focusOnLoad: false,
			  shortcut: {
			    modifier: 18,
			    fullscreen: 70,
			    preview: 80
			  }
			};
var editor = new EpicEditor(opts);

var list = $(".Markdown");
list.each(function(i){
    var dom=list[i];
    dom.innerHTML=editor.settings.parser(dom.innerHTML);
});
