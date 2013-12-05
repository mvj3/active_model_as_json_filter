active_model_as_json_filter
===========================
直接通过配置属性来生成as_json。


说明
---------------------------
不要直接覆写as_json，否则分配在多个文件的model的json会混乱，不知道谁改写了谁。

改用ActiveModel::AsJsonFilter可以直接通过配置属性来生成as_json。

示例
---------------------------

```ruby
class App
  self.as_json_options.except.add(:classroom_ids)
end
```

* 配置as_json参数

Model的属性 ExampleModel.as_json_options 均可以通过 as_json 本身支持的 only,
except, methods 来 add 附加字段，如果不设置，就和 as_json 默认行为一样。

* 配置全局和局部回调, 该功能解决了完全自定义的问题。

1. 可以在全局层面配置:

```ruby
ActiveModel::AsJsonFilter.finalizer_proc = lambda do |result|
 result['id'] = result['uuid'] if result['uuid']
 return result
end
```

2. 也可以在局部层面配置

```ruby
ExampleModel.as_json_options.finalizer_proc = lambda do |result, item|
  result['download_url'] = item.current_version.download_url
  return result
end
```

3. 两者都在as_json最后调用，并且局部会覆盖全局。
