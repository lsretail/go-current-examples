// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

page 50101 ApiPage
{
    trigger OnOpenPage();
    var
        helpers: Codeunit Helpers;
    begin
        helpers.Edit();
        Message('App published: Hello world');
    end;
}