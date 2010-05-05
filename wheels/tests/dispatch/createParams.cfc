<cfcomponent extends="wheelsMapping.test">

	<cfset global.ParamsParser = createobject("component", "wheelsMapping.ParamsParser").init()>
	<cfset global.args = {}>
	<cfset global.args.path = "home">
	<cfset global.args.route = {pattern="", controller="wheels", action="wheels"}>
	<cfset global.args.formScope = {}>
	<cfset global.args.urlScope = {}>

	<cffunction name="test_default_day_to_1">
		<cfset loc.args.formScope["obj[published]($month)"] = 2>
		<cfset loc.args.formScope["obj[published]($year)"] = 2000>
		<cfset loc.params = loc.ParamsParser.create(argumentCollection=loc.args)>
		<cfset loc.e = loc.params.obj.published>
		<cfset loc.r = CreateDateTime(2000, 2, 1, 0, 0, 0)>
		<cfset assert('datecompare(loc.r, loc.e) eq 0')>
	</cffunction>

	<cffunction name="test_default_month_to_1">
		<cfset loc.args.formScope["obj[published]($day)"] = 30>
		<cfset loc.args.formScope["obj[published]($year)"] = 2000>
		<cfset loc.params = loc.ParamsParser.create(argumentCollection=loc.args)>
		<cfset loc.e = loc.params.obj.published>
		<cfset loc.r = CreateDateTime(2000, 1, 30, 0, 0, 0)>
		<cfset assert('datecompare(loc.r, loc.e) eq 0')>
	</cffunction>

	<cffunction name="test_default_year_to_1899">
		<cfset loc.args.formScope["obj[published]($year)"] = 1899>
		<cfset loc.params = loc.ParamsParser.create(argumentCollection=loc.args)>
		<cfset loc.e = loc.params.obj.published>
		<cfset loc.r = CreateDateTime(1899, 1, 1, 0, 0, 0)>
		<cfset assert('datecompare(loc.r, loc.e) eq 0')>
	</cffunction>

	<cffunction name="test_url_and_form_scope_map_the_same">
		<cfset structinsert(loc.args.urlScope, "user[email]", "tpetruzzi@gmail.com", true)>
		<cfset structinsert(loc.args.urlScope, "user[name]", "tony petruzzi", true)>
		<cfset structinsert(loc.args.urlScope, "user[password]", "secret", true)>
		<cfset loc.args.formScope = {}>
		<cfset loc.url_params = loc.ParamsParser.create(argumentCollection=loc.args)>
		<cfset loc.args.formScope = duplicate(loc.args.urlScope)>
		<cfset loc.args.urlScope = {}>
		<cfset loc.form_params = loc.ParamsParser.create(argumentCollection=loc.args)>
		<cfset assert('loc.url_params.toString() eq loc.form_params.toString()')>
	</cffunction>

	<cffunction name="test_url_overrides_form">
		<cfset structinsert(loc.args.urlScope, "user[email]", "per.djurner@gmail.com", true)>
		<cfset structinsert(loc.args.formScope, "user[email]", "tpetruzzi@gmail.com", true)>
		<cfset structinsert(loc.args.formScope, "user[name]", "tony petruzzi", true)>
		<cfset structinsert(loc.args.formScope, "user[password]", "secret", true)>
		<cfset loc.params = loc.ParamsParser.create(argumentCollection=loc.args)>
		<cfset loc.e = {}>
		<cfset loc.e.email = "per.djurner@gmail.com">
		<cfset loc.e.name = "tony petruzzi">
		<cfset loc.e.password = "secret">
		<cfloop collection="#loc.params.user#" item="loc.i">
			<cfset assert('structkeyexists(loc.e, loc.i)')>
			<cfset assert('loc.e[loc.i] eq loc.params.user[loc.i]')>
		</cfloop>
	</cffunction>

	<cffunction name="test_form_scope_not_overwritten">
		<cfset loc.args.formScope["obj[published]($month)"] = 2>
		<cfset loc.params = loc.ParamsParser.create(argumentCollection=loc.args)>
		<cfset loc.exists = StructKeyExists(loc.args.formScope, "obj[published]($month)") />
		<cfset assert('loc.exists eq true')>
	</cffunction>

	<cffunction name="test_url_scope_not_overwritten">
		<cfset StructInsert(loc.args.urlScope, "user[email]", "tpetruzzi@gmail.com", true)>
		<cfset loc.params = loc.ParamsParser.create(argumentCollection=loc.args)>
		<cfset loc.exists = StructKeyExists(loc.args.urlScope, "user[email]") />
		<cfset assert('loc.exists eq true')>
	</cffunction>

	<cffunction name="test_multiple_objects_with_checkbox">
		<cfset StructInsert(loc.args.urlScope, "user[1][isActive]($checkbox)", "0", true)>
		<cfset StructInsert(loc.args.urlScope, "user[1][isActive]", "1", true)>
		<cfset StructInsert(loc.args.urlScope, "user[2][isActive]($checkbox)", "0", true)>
		<cfset loc.params = loc.ParamsParser.create(argumentCollection=loc.args)>
		<cfset assert('loc.params.user["1"].isActive eq 1') />
		<cfset assert('loc.params.user["2"].isActive eq 0') />
	</cffunction>

	<cffunction name="test_multiple_objects_in_objects">
		<cfscript>
			loc.args.formScope["user"]["1"]["config"]["1"]["isValid"] = true;
			loc.args.formScope["user"]["1"]["config"]["2"]["isValid"] = false;
			loc.params = loc.ParamsParser.create(argumentCollection=loc.args);
			assert('IsStruct(loc.params.user) eq true');
			assert('IsStruct(loc.params.user[1]) eq true');
			assert('IsStruct(loc.params.user[1].config) eq true');
			assert('IsStruct(loc.params.user[1].config[1]) eq true');
			assert('IsStruct(loc.params.user[1].config[2]) eq true');
			assert('IsBoolean(loc.params.user[1].config[1].isValid) eq true');
			assert('IsBoolean(loc.params.user[1].config[2].isValid) eq true');
			assert('loc.params.user[1].config[1].isValid eq true');
			assert('loc.params.user[1].config[2].isValid eq false');
		</cfscript>
	</cffunction>

</cfcomponent>
