# Planet Site Templates

Built-in site templates in [Project Planet](https://github.com/Planetable/Planet).

## Initial Pull

```
git clone --recurse-submodules https://github.com/Planetable/PlanetSiteTemplates
```

## Sync with Sub Projects

```
git submodule update --remote
git add Sources
git commit -m "commit message"
git tag -a 0.2.3 -m "tag message"
git push origin main --tags
```

## To-Do

- [ ] Find a way to make this part of the main Planet app repo. A monorepo would be better.
