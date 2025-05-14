# Planet Site Templates

Built-in site templates in [Project Planet](https://github.com/Planetable/Planet).

* [Plain](https://github.com/Planetable/SiteTemplatePlain)
* [8-bit](https://github.com/Planetable/SiteTemplate8bit)
* [Grid](https://github.com/Planetable/SiteTemplateGrid)
* [Croptop](https://github.com/Planetable/SiteTemplateCroptop)
* [Sepia](https://github.com/Planetable/SiteTemplateSepia)
* [Memories](https://github.com/Planetable/SiteTemplateMemories)

## Initial Pull

```
git clone --recurse-submodules https://github.com/Planetable/PlanetSiteTemplates
```

If it is the first time you pull the repo, use the following command to check out all submodules.

```
git submodule update --init --recursive
```

## Sync with Sub Projects

```
git pull
git submodule update --remote
git add Sources
git commit -m "commit message"
git tag -a 0.2.3 -m "tag message"
git push origin main --tags
```

## Add a New Template as a Submodule

For example, `sepia` is a new template for microblogging, and you can add it as a submodule to the `Sources/PlanetSiteTemplates/Resources` folder like this:

```
cd Sources/PlanetSiteTemplates/Resources
git submodule add https://github.com/Planetable/SiteTemplateMemories memories
```

## To-Do

- [ ] Find a way to make this part of the main Planet app repo. A monorepo would be better.
- [ ] Template browser UI needs a way to add new templates.