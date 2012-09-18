function htmlarea_with_cache(compoment,id){
	$(compoment).htmlarea();
	var old_content=$(compoment)[0].value;
	if($("#subject").length>0){
		setTimeout("check_content_title_modify('"+compoment+"','"+old_content+"','"+$("#subject")[0].value+"','"+id+"')",1000);
	} else {
		setTimeout("check_content_modify('"+compoment+"','"+old_content+"','"+id+"')",1000);
	}
	$.getJSON('/cache/'+id,function(data){
		if(data!=null){
			var con = confirm("Load cache content?");
			if(con){
				if($("#subject").length>0){
					$("#subject")[0].value=data.Subject;
				}
				$(compoment).htmlarea("dispose");
				$(compoment)[0].value=data.Body;
				$(compoment).htmlarea();
			}
		}
	});
}

function check_content_title_modify(compoment,old_content,old_titls,id){
	var new_content=$(compoment)[0].value;
	if (old_content==new_content && old_titls==$("#subject")[0].value) {
		setTimeout("check_content_title_modify('"+compoment+"','"+old_content+"','"+old_titls+"','"+id+"')",1000);		
	} else {
		var data={
			subject: $("#subject")[0].value,
			body: $(compoment)[0].value
		};
		$.post("/cache/"+id,data,function(){
			old_content=$(compoment)[0].value;
			old_titls=$("#subject")[0].value;
			setTimeout("check_content_title_modify('"+compoment+"','"+old_content+"','"+old_titls+"','"+id+"')",1000);
		});
	}
}

function check_content_modify(compoment,old_content,id){
	var new_content=$(compoment)[0].value;
	if (old_content==new_content) {
		setTimeout("check_content_modify('"+compoment+"','"+old_content+"','"+id+"')",1000);		
	} else {
		var data={
			body: $(compoment)[0].value
		};
		$.post("/cache/"+id,data,function(){
			old_content=$(compoment)[0].value;
			setTimeout("check_content_modify('"+compoment+"','"+old_content+"','"+id+"')",1000);
		});
	}
}