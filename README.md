# Planet Site Templates

Built-in site templates in [Project Planet](https://github.com/Planetable/Planet).

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

## To-Do

- [ ] Find a way to make this part of the main Planet app repo. A monorepo would be better.
