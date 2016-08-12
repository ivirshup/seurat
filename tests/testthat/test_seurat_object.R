# Tests for functions dependent on a seurat object

# load a minimal example data set (subset of nbt dataset)
load("../testdata/nbt_small.Rdata")


# Tests for object creation (via new/Setup)
# --------------------------------------------------------------------------------
context("Object creation")

# Generate Seurat object
min_cells <- 3
project_name <- "NBT_TEST"
names_field <- 2
names_delim <- "_"
min_genes <- 1000
expression_thresh <- 1

nbt_test <- new("seurat", raw.data = nbt_small)

test_that("object initialization creates seurat object", {
  expect_is(nbt_test, "seurat")
})

nbt_test <- Setup(nbt_test, project = project_name, min.cells = min_cells, names.field = names_field,
                  names.delim = names_delim, min.genes = min_genes, is.expr = expression_thresh,
                  large.object = T )

test_that("entered parameters set correctly", {
  expect_match(project_name, nbt_test@project.name)
  expect_equal(expression_thresh, nbt_test@is.expr)


})

test_that("correct cells are used",{
  gene_count <- unname(findNGene(nbt_test@raw.data, nbt_test@is.expr))
  expect_equal(min(gene_count), 2405)
  expect_true(all(gene_count >= min_genes))
})

test_that("correct genes are used", {
  usuable_genes <- rowSums(nbt_test@raw.data > expression_thresh)
  usuable_genes <- usuable_genes[usuable_genes >= min_cells]
  used_genes <- rownames(nbt_test@data)

  expect_true(length(usuable_genes) > 0)
  expect_equal(length(usuable_genes), length(used_genes))
})

test_that("names and IDs set correctly", {
  expect_true(length(colnames(nbt_test@raw.data)) > 0)
  expect_equal(nbt_test@cell.names, colnames(nbt_test@raw.data))

  expected_cluster_ids = c("GW21.2", "GW16", "GW21")
  expect_equal(as.vector(unique(nbt_test@ident)), expected_cluster_ids)
  expect_equal(as.vector(unique(nbt_test@ident)), as.vector(unique(nbt_test@data.info$orig.ident)))

})

test_that("scaling done correctly", {
  expect_equal(nbt_test@scale.data["AACS", "Hi_GW21.2_3"], 1.66900902464456)
  expect_equal(nbt_test@scale.data["ZYX", "Hi_GW16_1"], -0.658326175185112)
})

test_that("nGene calculations are consistent" , {
  gene_count <- unname(findNGene(nbt_test@raw.data, nbt_test@is.expr))
  expect_equal(nbt_test@mix.probs[, 1], gene_count)
  expect_equal(nbt_test@gene.scores[, 1], gene_count)

})


# Test PCA dimensional reduction
# --------------------------------------------------------------------------------
context("PCA dimensional reduction")

nbt_test <- MeanVarPlot(nbt_test, y.cutoff = 2,x.low.cutoff = 2,fxn.x = expMean,fxn.y = logVarDivMean)
nbt_test <- PCA(nbt_test, do.print=FALSE)

test_that("PCA returns expected data", {

  expect_is(nbt_test@pca.rot, "data.frame")
  expect_is(nbt_test@pca.x, "data.frame")
  expect_true(length(nbt_test@pca.rot) != 0)
  expect_true(length(nbt_test@pca.x) != 0)
  expect_equal(ncol(nbt_test@pca.rot), length(nbt_test@var.genes))

})


# Tests for plotting functionality (via Setup)
# --------------------------------------------------------------------------------
context("Plotting/Visualization")

test_that("Violin plots (VlnPlot() ) return as expected", {
  expect_is(VlnPlot(nbt_test, "ZYX", do.ret = T)[[1]]$layers[[1]]$geom, "GeomViolin" )
  expect_equal(length(VlnPlot(nbt_test, c("ZYX", "AACS"), do.ret = T)), 2)

})

test_that("CellPlots return as expected", {
  expect_equal(CellPlot(nbt_test, nbt_test@cell.names[1], nbt_test@cell.names[2]), NULL)
})

test_that("GenePlots return as expected", {
  expect_equal(GenePlot(nbt_test,"DLX1","DLX2"), NULL)
})

test_that("MeanVarPlotworks as expected", {
  expect_is(MeanVarPlot(nbt_test, y.cutoff = 2,x.low.cutoff = 2,fxn.x = expMean,fxn.y = logVarDivMean), "seurat")
})


# Tests for plotting functionality (via Setup)
# --------------------------------------------------------------------------------
context("Clustering Functions")

test_that("SNN will be built if not present", {
  expect_true(length(nbt_test@snn.dense) == 0)
  expect_true(length(nbt_test@snn.sparse) == 0)

  nbt_test <- FindClusters(nbt_test, pc.use = 1:8, print.output = 0, update = 0, k.param = 4, k.scale = 1, save.SNN = T)
  expect_true(length(nbt_test@snn.dense) > 1)

  nbt_test <- FindClusters(nbt_test, pc.use = 1:8, print.output = 0, update = 0, k.param = 4, k.scale = 1, do.sparse = T, save.SNN = T)

  expect_true(length(nbt_test@snn.dense) == 1)
  expect_true(length(nbt_test@snn.sparse) > 1)


})


