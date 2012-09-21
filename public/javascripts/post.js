var block_list={};

function close_dialog(id){
	if ($("#"+id+" .bar #dialog").length>0){
		$("#"+id+" .bar #dialog").remove();
	}
}

function add_block_text(id,type){
	var text=$("#txtDefaultHtmlArea")[0].value;
	if(type=="comment"){
		var comment_type=$('#comment_type')[0].value
		var comment_title=$('#comment_title')[0].value
	}
	$.post("/"+type+"_block/"+id,{"text":text,"comment_type":comment_type,"comment_title":comment_title},function(data, textStatus, jqXHR){
		if(data=="OK"){
			window.location='/post/'+article_id;
		} else {
			alert(data);
		}
	});
}

function add_left_block(id){
	var comment_type=$('#comment_type')[0].value
	var left_id=$('#left_id')[0].value
	$.post("/add_left_block/"+id,{"comment_type":comment_type,"left_id":left_id},function(data, textStatus, jqXHR){
		if(data=="OK"){
			window.location='/post/'+article_id;
		} else {
			alert(data);
		}
	});	
}

function add_exist_block(id){
	var exist_id=$('#exist_id')[0].value
	$.post("/add_exist_block/"+id,{"exist_id":exist_id},function(data, textStatus, jqXHR){
		if(data=="OK"){
			window.location='/post/'+article_id;
		} else {
			alert(data);
		}
	});	
}

function edit_block_text(id){
	var text=$("#txtDefaultHtmlArea")[0].value;
	$.post("/edit_block/"+id,{"text":text},function(data, textStatus, jqXHR){
		if(data=="OK"){
			window.location='/post/'+article_id;
		} else {
			alert(data);
		}
	});
}

function clone_block(id){
	$.post("/clone_block/"+id,{},function(data, textStatus, jqXHR){
		if(data=="OK"){
			window.location='/post/'+article_id;
		} else {
			alert(data);
		}
	});
}

function add_block(id,type){
	close_dialog(id);
	var dialog_html="<div id=\"dialog\">";
	if(type=="comment"){
		dialog_html=dialog_html+"<div id=\"comment_bar\">";
		dialog_html=dialog_html+"Subject: <input type=\"text\" name=\"comment_title\" id=\"comment_title\" value=\"comment:"+$("#title")[0].innerHTML+"\"> ";
		dialog_html=dialog_html+"<input type=\"hidden\" id=\"comment_type\" value=\"#056\">";
		dialog_html=dialog_html+"<input type=\"radio\" name=\"comment_type\" onclick=\"javascript:$('#comment_type')[0].value='#00f';\"> yes ";
		dialog_html=dialog_html+"<input type=\"radio\" name=\"comment_type\" onclick=\"javascript:$('#comment_type')[0].value='#f00';\"> no ";
		dialog_html=dialog_html+"<input type=\"radio\" name=\"comment_type\" onclick=\"javascript:$('#comment_type')[0].value='#056';\" checked> comment ";
		dialog_html=dialog_html+"</div>";
	}
	dialog_html=dialog_html+"<br /><textarea id=\"txtDefaultHtmlArea\" cols=\"50\" rows=\"15\"></textarea>";
	dialog_html=dialog_html+"<button class=\"btn btn-primary\" onclick=\"javascript:add_block_text('"+id+"','"+type+"')\">submit</button>";
	dialog_html=dialog_html+"&nbsp;&nbsp;<button class=\"btn btn-inverse\" onclick=\"javascript:close_dialog('"+id+"');\">close</button>";
	dialog_html=dialog_html+"</div>";
	$("#"+id+" .bar").append(dialog_html);
	$("#txtDefaultHtmlArea").width($("#"+id+" .bar").width());
	htmlarea_with_cache("#txtDefaultHtmlArea","add_"+type+"_"+id);
}

function add_left(id){
	close_dialog(id);
	var dialog_html="<div id=\"dialog\">";
	dialog_html=dialog_html+"<div id=\"comment_bar\">";
	dialog_html=dialog_html+"<input type=\"hidden\" id=\"comment_type\" value=\"#056\">";
	dialog_html=dialog_html+"<input type=\"radio\" name=\"comment_type\" onclick=\"javascript:$('#comment_type')[0].value='#00f';\"> yes ";
	dialog_html=dialog_html+"<input type=\"radio\" name=\"comment_type\" onclick=\"javascript:$('#comment_type')[0].value='#f00';\"> no ";
	dialog_html=dialog_html+"<input type=\"radio\" name=\"comment_type\" onclick=\"javascript:$('#comment_type')[0].value='#056';\" checked> comment ";
	dialog_html=dialog_html+"&nbsp;&nbsp; BlockID:<input type=\"text\" id=\"left_id\">";
	dialog_html=dialog_html+"</div>";
	dialog_html=dialog_html+"<button class=\"btn btn-primary\" onclick=\"javascript:add_left_block('"+id+"')\">submit</button>";
	dialog_html=dialog_html+"&nbsp;&nbsp;<button class=\"btn btn-inverse\" onclick=\"javascript:close_dialog('"+id+"');\">close</button>";
	dialog_html=dialog_html+"</div>";
	$("#"+id+" .bar").append(dialog_html);
}

function add_exist(id){
	close_dialog(id);
	var dialog_html="<div id=\"dialog\">";
	dialog_html=dialog_html+"<div id=\"comment_bar\">";
	dialog_html=dialog_html+"&nbsp;&nbsp; BlockID:<input type=\"text\" id=\"exist_id\">";
	dialog_html=dialog_html+"</div>";
	dialog_html=dialog_html+"<button class=\"btn btn-primary\" onclick=\"javascript:add_exist_block('"+id+"')\">submit</button>";
	dialog_html=dialog_html+"&nbsp;&nbsp;<button class=\"btn btn-inverse\" onclick=\"javascript:close_dialog('"+id+"');\">close</button>";
	dialog_html=dialog_html+"</div>";
	$("#"+id+" .bar").append(dialog_html);
}

function delete_block(id){
	$( "#dialog-block-confirm" ).dialog({
		resizable: false,
		height:140,
		modal: true,
		buttons: {
			"Delete": function() {
				$(this).dialog("close");
				$.post("/delete_block",{"id":id},function(data, textStatus, jqXHR){
					if(data=="OK"){
						window.location='/post/'+article_id;
					}
					if(data=="OK_ALL"){
						window.location="/home";
					}
				});
			},
			Cancel: function() {
				$(this).dialog("close");
			}
		}
	});
}

function delete_link(conn){
	$( "#dialog-link-confirm" ).dialog({
		resizable: false,
		height:140,
		modal: true,
		buttons: {
			"Delete": function() {
				$(this).dialog("close");
				$.post("/delete_link",{"id":conn.sourceId,"left_id":conn.targetId},function(data, textStatus, jqXHR){
					if(data=="OK"){
						window.location='/post/'+article_id;
					}
				});
			},
			Cancel: function() {
				$(this).dialog("close");
			}
		}
	});
}

function edit_block(id){
	close_dialog(id);
	var dialog_html="<div id=\"dialog\">";
	dialog_html=dialog_html+"<br /><textarea id=\"txtDefaultHtmlArea\" cols=\"50\" rows=\"15\">";
	dialog_html=dialog_html+block_list[id];
	dialog_html=dialog_html+"</textarea>";
	dialog_html=dialog_html+"<button class=\"btn btn-primary\" onclick=\"javascript:edit_block_text('"+id+"')\">submit</button>";
	dialog_html=dialog_html+"&nbsp;&nbsp;<button class=\"btn btn-inverse\" onclick=\"javascript:close_dialog('"+id+"');\">close</button>";
	dialog_html=dialog_html+"</div>";
	$("#"+id+" .bar").append(dialog_html);
	$("#txtDefaultHtmlArea").width($("#"+id+" .bar").width());
	htmlarea_with_cache("#txtDefaultHtmlArea","edit_"+id);	
}

function make_block_html(block,type,avatar_html){
	if(type=="main"){
		var html="<div class =\"component\" id=\"b"+block.Id+"\">";
		html=html+"<div class=\"hide blockid\">"+block.Id+"<br /></div>\n";
	} else {
		var html="<div class =\"component comment well\" id=\"b"+block.Id+"\">";
	}

	if (block.Subject!=null && type!='main'){
		if(block.ParentId){
			html=html+"\n<strong><a href=\"/post/"+block.ParentId+"\">"+block.Subject+"</a></strong><br/>\n";
		} else {
			block.Id=block.Id.substring(1,26);
			html=html+"\n<strong><a href=\"/post/"+block.Id+"\">"+block.Subject+"</a></strong><br/>\n";
		}
	}
	if(block.ParentId==null && block.Public==1){
		html=html+"\n<div id=\"user_"+block.AuthorId+"\" class=\"avatar\">"+avatar_html+"</div>";
	}
	html=html+block.Body+"<br/>\n";
	if(type=="main"){
		html=html+"<div class=\"bar\">\n";
		if(is_author==true){
			html=html+"<button class=\"btn btn-danger hide\" onclick=\"javascript:delete_block('b"+block.Id+"')\">delete</button>";
			html=html+"&nbsp;<button class=\"btn btn-warning hide\" onclick=\"javascript:edit_block('b"+block.Id+"')\">edit</button>";
			html=html+"&nbsp;<button class=\"btn btn-info hide\" onclick=\"javascript:clone_block('b"+block.Id+"')\">clone</button>";
			html=html+"&nbsp;<div class=\"btn-group pull-right hide\">\n";
			html=html+"<a class=\"btn btn-inverse dropdown-toggle\" data-toggle=\"dropdown\" href=\"#\">\n";
			html=html+"add<span class=\"caret\"></span></a>\n";
			html=html+"<ul class=\"dropdown-menu\">\n";
			html=html+"<li><a href=\"#\" onclick=\"javascript:add_block('b"+block.Id+"','append');return false;\">block</a></li>\n";
			html=html+"<li><a href=\"#\" onclick=\"javascript:add_block('b"+block.Id+"','comment');return false;\">comment</a></li>\n";
			html=html+"<li><a href=\"#\" onclick=\"javascript:add_left('b"+block.Id+"');return false;\">left</a></li>\n";
			html=html+"<li><a href=\"#\" onclick=\"javascript:add_exist('b"+block.Id+"');return false;\">exist</a></li>\n";
			html=html+"</ul>\n";
			html=html+"</div>\n";
		} else {
			html=html+"<button class=\"btn btn-info hide\" onclick=\"javascript:clone_block('b"+block.Id+"')\">clone</button>";
			html=html+"&nbsp;<button class=\"btn btn-primary hide\" onclick=\"javascript:add_block('b"+block.Id+"','comment')\">comment</button>";
		}
	} else {
		html=html+"<div class=\"pull-right\" style=\"font-size:10px;color:#777;\"><i class=\"icon-comment\"></i>"+block.RightBlockCount+"</div>";
	}
	html=html+"</div>"
	return html;
}

function add_hover(id){
	$(id).hover(
		function(){
			if($(id+" .bar #dialog").length==0){
				$(this).addClass("hover");
			}
		},
		function(){
			if($(id+" .bar #dialog").length==0){
				$(this).removeClass("hover");
			}
		}
	);
}

function add_header_hover(){
	$("#header").hover(
		function(){
			$(this).addClass("hover");
		},
		function(){
			$(this).removeClass("hover");
		}
	);
}

function next_top(show_id,_middle_id,top){
		var _show_id="#"+show_id;
		if(($(_middle_id)[0].offsetTop-70)>top){
			$(_show_id)[0].style.marginTop=($(_middle_id)[0].offsetTop-70)+"px";
			top=$(_middle_id)[0].offsetTop-70+$(_show_id)[0].clientHeight+5;
		} else {
			$(_show_id)[0].style.marginTop=top+"px";
			top=top+$(_show_id)[0].clientHeight+5;
		}
		return top;
}

function show_left_block(top,article,sub_block){
	var middle_id="b"+sub_block.Id;
	var _middle_id="#"+middle_id;
	if (article.left_blocks[sub_block.Id].length>0){
		for(var j=0;j<article.left_blocks[sub_block.Id].length;j++){
			var show_block=article.left_blocks[sub_block.Id][j];
			show_block.Id="l"+show_block.Id;
			var show_id="b"+show_block.Id;
			$("#left_sortable").append(make_block_html(show_block,"left",article.users[show_block.AuthorId]));
			top=next_top(show_id,_middle_id,top);
			var connector = {
				connector:"StateMachine",
				container:"left",
				paintStyle:{lineWidth:3,strokeStyle:show_block.Type},
				detachable:false,
				hoverPaintStyle:{strokeStyle:"#dbe300"},
				endpoint:"Blank",
				anchors:[ [ 0, 0.5, 0, 0 ], [1, 0.5, 0, 0] ],
				overlays:[ ["PlainArrow", {location:1, width:10, length:6} ]]
			};
			jsPlumb.connect({source:middle_id,target:show_id},connector);
		}
	}
	return top;
}

function show_right_block(top,article,sub_block){
	var middle_id="b"+sub_block.Id;
	var _middle_id="#"+middle_id;
	if(article.right_blocks[sub_block.Id].length>0){
		for(var j=0;j<article.right_blocks[sub_block.Id].length;j++){
			var show_block=article.right_blocks[sub_block.Id][j];
			show_block.Id="r"+show_block.Id;
			var show_id="b"+show_block.Id;
			$("#right_sortable").append(make_block_html(show_block,"right",article.users[show_block.AuthorId]));
			top=next_top(show_id,_middle_id,top);
			var connector = {
				connector:"StateMachine",
				container:"middle",
				paintStyle:{lineWidth:3,strokeStyle:show_block.Type},
				detachable:false,
				hoverPaintStyle:{strokeStyle:"#dbe300"},
				endpoint:"Blank",
				anchors:[ [ 0, 0.5, 0, 0 ], [1, 0.5, 0, 0] ],
				overlays:[ ["PlainArrow", {location:1, width:10, length:6} ]]
			};
			jsPlumb.connect({source:show_id,target:middle_id},connector);
		}
	}
	return top;	
}

function show_article(article){
		var left_top=0;
		var right_top=0;
		block_list["b"+article.main_block.Id]=article.main_block.Body;
		for(var i=0;i<article.tags.length;i++){
			var tag=article.tags[i];
			$("#tags").append("&nbsp;<button class=\"btn btn-mini\" onclick=\"javascript:window.location='/tags/"+tag.Id+"';\">"+tag.Name+"</button>");
		}
		add_header_hover();
		$("#title")[0].innerHTML=article.main_block.Subject;
		$("#middle_sortable").append(make_block_html(article.main_block,"main",article.users[article.main_block.AuthorId]));
		add_hover("#b"+article.main_block.Id);
		left_top=show_left_block(left_top,article,article.main_block);
		right_top=show_right_block(right_top,article,article.main_block);
		for(var i=0;i<article.sub_blocks.length;i++){
			var sub_block=article.sub_blocks[i];
			block_list["b"+sub_block.Id]=sub_block.Body;
			$("#middle_sortable").append(make_block_html(sub_block,"main",""));
			add_hover("#b"+sub_block.Id);
			left_top=show_left_block(left_top,article,sub_block);
			right_top=show_right_block(right_top,article,sub_block);
			var middle_offset = $("#b"+sub_block.Id)[0].offsetTop+$("#b"+sub_block.Id)[0].clientHeight-70;
			if(right_top>middle_offset || left_top>middle_offset){
				var height=0;
				if(right_top>left_top){
					height=right_top-middle_offset;
				} else {
					height=left_top-middle_offset;
				}
				$("#middle_sortable").append("<div style=\"height:"+height+"px\"></div>");
			}
		}
}

jsPlumb.bind("ready", function() {
	jsPlumb.setRenderMode(jsPlumb.SVG);
	$.get('/article/'+article_id,function(result){
		var article=$.parseJSON(result);
		show_article(article);
	});
});
jsPlumb.bind("click", function(conn, originalEvent) {
	if(conn.parent=="left"){
		delete_link(conn);
	}
});

$(window).resize(function() {
	jsPlumb.repaintEverything();
});