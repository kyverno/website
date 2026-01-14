import { getCollection } from 'astro:content'

const posts = await getCollection('blog')
const post = posts.find((p) => p.id.includes('announcing-kyverno-release'))
if (post) {
  console.log('post.id:', post.id)
  console.log('post keys:', Object.keys(post))
  if (post.id) {
    console.log('post.id includes dot:', post.id.includes('.'))
  }
}
