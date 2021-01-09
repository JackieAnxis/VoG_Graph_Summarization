const graphFileName = "./DATA/cliqueStarClique.out"
// const graphFileName = "./DATA/miserables.out"
d3.text(graphFileName).then(function (text) {
    const rows = text.split("\n")
    const nodeSet = new Set()
    const links = []
    rows.filter((row) => row.length > 0).forEach((row) => {
        const [source, target, weight] = row.split(",")
        nodeSet.add(source)
        nodeSet.add(target)
        links.push({
            source,
            target,
        })
    })
    const nodes = [...nodeSet.values()].map((id) => ({
        id,
    }))
    const graph = { nodes, links }

    const width = 600
    const height = 600

    const color = { r: 51 / 255, g: 153 / 255, b: 52 / 255, a: 1 }
    const netv = new NetV({
        container: document.getElementById("container"),
        node: {
            style: {
                r: 8,
                fill: color,
            },
        },
        link: {
            style: {
                strokeWidth: 1,
            },
        },
        width,
        height,
    })

    const miserables = netv.loadDataset("miserables")
    let str = ""
    const miserablesNode2Index = new Map()
    miserables.nodes.forEach((node, index) => {
        miserablesNode2Index.set(node.id, index + 1)
    })
    miserables.links.forEach((link) => {
        str += `${miserablesNode2Index.get(
            link.source
        )},${miserablesNode2Index.get(link.target)},1\n`
    })
    console.log(str)

    netv.data(graph)

    const simulation = d3
        .forceSimulation(graph.nodes)
        .force(
            "link",
            d3.forceLink(graph.links).id((d) => d.id)
        )
        .force("charge", d3.forceManyBody())
        .force("center", d3.forceCenter(width / 2, height / 2))

    simulation.on("tick", () => {
        graph.nodes.forEach((n) => {
            const node = netv.getNodeById(n.id)
            node.x(n.x)
            node.y(n.y)
        })

        netv.draw()
    })

    netv.on("pan")
    netv.on("zoom")
    netv.nodes().forEach((node) => node.on("dragging"))

    const subgraphsFileName = "./DATA/cliqueStarClique_ALL.model"
    // const subgraphsFileName = "./DATA/miserables_orderedALL.model"
    d3.text(subgraphsFileName).then(function (text) {
        const rows = text.split("\n")
        const subgraphContainer = d3.select("#subgraphs")
        rows.filter((row) => row.length > 0).forEach((row) => {
            const [type, ...nodeIDs] = row.split(/\s/)
            if (type == "st") {
                console.log(nodeIDs)
            }
            const nodes = nodeIDs.map((id) => {
                const node = netv.getNodeById(id.replace(",", ""))
                if (!node) {
                    debugger
                }
                return node
            })
            subgraphContainer
                .append("button")
                .datum(nodes)
                .text(type)
                .on("mouseover", (nodes) => {
                    nodes.forEach((node) => {
                        node.fill({
                            r: 173 / 255,
                            g: 61 / 255,
                            b: 62 / 255,
                            a: 1,
                        })
                    })
                    netv.draw()
                })
                .on("mouseout", (nodes) => {
                    nodes.forEach((node) => {
                        node.fill(color)
                    })
                    netv.draw()
                })
        })
    })
})
